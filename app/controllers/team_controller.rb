class TeamController < ApplicationController
  
  before_filter :set_user, :set_team
  before_filter :set_permissions
  before_filter :check_approved, :only => ['submit', 'unsubmit', 'edit']
  
  def show
    @user = User.find_by_id(session[:user_id])
    return redirect_to login_path, :notice => "Please log in" if @user.nil?
    
    return redirect_to admin_path(@user.id) if session[:is_admin]

    return redirect_to without_team_path, :notice => "Your team does not exist" if @user.team.nil?
    
    @team = Team.find_by_id(params[:id])

    @discussions = Discussion.all
    render "team"
  end
  
  def submit
    redirect_to new_submission_path
  end
  
  def unsubmit
    @team.withdraw_submission
    redirect_to team_path(@team.id)
  end
  
  def edit
    @user_to_remove = User.find_by_id(params[:unwanted_user])
    @user_to_remove.leave_team
    @team.withdraw_submission
    notice = ""

    if @user.is_a? Admin and @team.approved
      @team.withdraw_approval
    elsif @team.submitted
      notice = " Your team's submission has been withdrawn."
    end
    
    return redirect_to without_team_path if @user_to_remove == @user
    return redirect_to team_path(@team.id), notice: "Removed #{@user_to_remove.name} from team." + notice
  end
  
  

  private
  
  def set_user
    if session[:is_admin]
      @user = Admin.find(session[:user_id])
    else
      @user = User.find(session[:user_id])
      redirect_to without_team_path, :notice => "Permission denied" if @user.team.nil?
    end
  end

  def set_team
    @team = Team.find_by_id(params[:id])
  end

  def set_permissions
    # checking that the team we are looking for exists and that the user doing the action on the team is either an admin or a student on the same team
    if @team.nil? or (session[:is_admin].nil? and @user.team != @team)
      redirect_to '/', :notice => "Permission denied"
    end
  end
  
  def check_approved
    redirect_to '/', :notice => "Permission denied" if @team.approved and !(@user.is_a? Admin)
  end

  
  
  
end