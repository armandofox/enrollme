class AdminsController < ApplicationController
  skip_before_filter :authenticate, :only => ['new', 'create']
  before_filter :validate_admin, :set_admin, :except => ['new', 'create']

  def new
    @admin = Admin.new
    render 'new'
  end

  def create
    @admin = Admin.new(admin_params)
    @admin.superadmin = false
    if session[:is_admin] == true and @admin.save
      AdminMailer.invite_new_admin(@admin).deliver_now
      redirect_to admins_path, :notice => "You created admin \
                        #{admin_params['name']} successfully!"
    else
      render 'new', :notice => "Form is invalid"
    end
  end

  def update
    @admin.update_attributes!(admin_params)
    return redirect_to admins_path
  end

  def index
    status = params[:status]
    @status = status
    @teams_li = Team.filter_by(status)
    render 'index'
  end

  def approve
    @team = Team.find_by_id(params[:team_id])
    @team.approved = true
    @team.save!

    AdminMailer.send_approved_email(@team).deliver_now

    if !(params[:disc].nil?)
      Team.find_by_id(params[:team_id]).approve_with_discussion(params[:disc])
    end
    redirect_to admins_path
  end

  def disapprove
    @team = Team.find_by_id(params[:team_id])
    @team.approved = false
    @team.save!

    #AdminMailer.send_disapproved_email(@team).deliver_now

    Team.find_by_id(params[:team_id]).disapprove
    redirect_to admins_path
  end

  def undo_approve
    @team = Team.find_by_id(params[:team_id])
    @team.approved = false
    @team.save!
    
    AdminMailer.send_disapproved_email(@team).deliver_now
    
    Team.find_by_id(params[:team_id]).withdraw_approval
    redirect_to admins_path
  end
  
  def team_list_email
    # AdminMailer.team_list_email(@admin).deliver_now
    redirect_to admins_path
  end
  
  def superadmin
    render "super"
  end
  
  def reset_semester
    render "reset"
  end
  
  def reset_database
    @reset_password = params[:reset_password]
    if @reset_password == ENV["ADMIN_DELETE_DATA_PASSWORD"]
      AdminMailer.all_data(@admin).deliver_now unless Rails.env.test?
      delete_all_database_columns
      redirect_to "/", :notice => "All data reset. Good luck with the new semester!"
    else
      redirect_to reset_semester_path, :notice => "Incorrect password"
    end
  end

  def transfer
    if @admin.superadmin == true and params[:transfer_admin] != nil
      other_admin = Admin.find(params[:transfer_admin])
      @admin.superadmin = false
      other_admin.superadmin = true
      @admin.save!
      other_admin.save!
      notice = "Successfully transferred superadmin powers."
    elsif @admin.superadmin == true and params[:transfer_admin] === nil
      notice = "No admin selected for transfer."
    else
      notice = "You don't have permission to do that."
    end
    redirect_to superadmin_path, :notice => notice
  end

  def delete
    if @admin.superadmin == true
      c = 0
      for a in Admin.all
        if params.has_key? "delete_#{a.name}"
          a.destroy!
          c += 1
        end
      end

      if c == 1
        notice = "#{c} admin successfully deleted."
      else
        notice = "#{c} admins successfully deleted."
      end
    else
      notice = "You do not have sufficient permissions to do that."
    end
    redirect_to superadmin_path, :notice => notice
  end

  def destroy
    if @admin.superadmin == false
      @admin.destroy!
      notice = "You have successfully deleted your admin account."
    else
      notice = "Please give someone else superadmin powers before deleting yourself."
    end
    redirect_to '/', :notice => notice
  end

  def skills
    @skills = Skill.where(:active => true)
    render 'skills'
  end

  def add_skill
    skill_name = params[:skill].titleize
    existing_skill = Skill.where(:name => skill_name).first
    if existing_skill
      if existing_skill.active
        notice = "Skill #{skill_name} already exists."
        return redirect_to skills_path, :notice => notice
      else
        existing_skill.active = true
        existing_skill.save
      end
    else
      skill = Skill.new(:name => skill_name, :active => true)
      skill.save!
    end
    notice = "Skill #{skill_name} successfully created."
    redirect_to skills_path, :notice => notice
  end

  def delete_skill
    skill = Skill.find_by_id(params[:id])
    if !skill
      notice = "Could not find skill to be deleted."
    else
      notice = "Sucessfully deleted #{skill.name}."
      skill.active = false
      skill.save
    end
    redirect_to skills_path, :notice => notice
  end

  def edit_skill
    @skill = Skill.find_by_id(params[:id])
    if request.patch?
      notice = edit_skill_populated_name_check(params[:name])
      redirect_to skills_path, :notice => notice
    else
      render 'edit_skill'
    end
  end

  private

  def validate_admin
    if !(session[:is_admin])
      redirect_to '/', :notice => "Permission denied"
    end
  end

  def set_admin
    @admin = Admin.find_by_id session[:user_id]
  end

  def admin_params
    params.require(:admin).permit(:name, :email)
  end

  def admin_tutorial
    render 'admin_tutorial'
  end

  def delete_all_database_columns
    User.delete_all
    Team.delete_all
    Submission.delete_all
    Discussion.delete_all
  end

  def edit_skill_populated_name_check(edit_name)
    if Skill.where(:name => edit_name).blank?
      return edit_skill_non_populated_name(@skill, edit_name)
    else
      return edit_skill_populated_name(edit_name)
    end
  end

  def edit_skill_populated_name(edit_name)
    existing_skill = Skill.where(:name => edit_name)[0]
    if !existing_skill.active
      return edit_skill_populated_name_active(@skill, existing_skill)
    else
      return "#{existing_skill.name} skill already exists."
    end
  end

  def edit_skill_non_populated_name(skill, edit_skill_name)
    skill.name = edit_skill_name
    skill.save
    return "#{skill.name} skill name updated successfully."
  end

  def edit_skill_populated_name_active(skill, existing_skill)
    existing_skill.active = true
    existing_skill.save
    skill = existing_skill
    return "#{skill.name} skill name updated successfully."
  end
end
