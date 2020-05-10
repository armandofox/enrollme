# Controller for dealing with teams and team's students' skills.
class TeamController < ApplicationController
  before_filter :set_user, :set_team
  before_filter :check_approved, only: %w(submit unsubmit edit)
  before_filter :check_can_send, only: %w(email)
  before_filter :set_permissions, except: %w(email do_email)
  before_action :fetch_team, only: %w(email do_email)

  def email
    render 'email'
  end

  def add_teammate
    user_to_add = User.find params[:userId]
    @team.users.append(user_to_add)
    @team.save!
    user_to_add.save!
    notice_msg = "Added #{user_to_add.name} to team."
    redirect_to team_path(@team.id), notice: notice_msg
  end

  def do_email
    @to.each_with_index do |to_email, counter|
      email_team_paramters = { to: to_email,
                               from_name: @user.name,
                               to_name: @names[counter],
                               subject: @subject,
                               body: @body,
                               reply_to: @user.email,
                               team: @team }
      TeamMailer.email_team(email_team_paramters).deliver_now
    end
    @user.email_team(@team.id)
    @user.save!
    redirect_to team_list_path, notice: 'Email sent successfully.'
  end

  def show
    @discussions = Discussion.valid_discs_for(@team)
    if @team.submitted and !(@team.approved)
      @s = Submission.find(@team.submission_id)
      @d1 = Discussion.find(@s.disc1id)
      @d2 = Discussion.find_by_id(@s.disc2id)
      @d3 = Discussion.find_by_id(@s.disc3id)
    end
    render "team"
  end

  def submit
    EmailStudents.successfully_submitted_email(@team).deliver_now

    redirect_to new_submission_path
  end

  def unsubmit
    @submission = @team.submission
    @submission.destroy!
    @team.withdraw_submission
    redirect_to team_path(@team.id)
  end

  def edit
    @user_to_remove = User.find_by_id(params[:unwanted_user])
    @user_to_remove.leave_team
    notice = ""

    if @user.is_a? Admin and @team.approved
      @team.disapprove
    elsif @team.submitted
      notice = " Your team's submission has been withdrawn."
    end

    @team.withdraw_submission
    return redirect_to without_team_path if @user_to_remove == @user
    return redirect_to team_path(@team.id), notice: "Removed #{@user_to_remove.name} from team." + notice
  end

  private

  def fetch_team
    @team = Team.find_by_id(params[:id])
    @to = @team.users.map(&:email).compact
    @subject = params['Subject']
    @body = params['Message']
    @names = @team.users.map(&:name)
  end

  def set_user
    if session[:is_admin]
      @user = Admin.find(session[:user_id])
    else
      @user = User.find(session[:user_id])
      validate_permissions
    end
  end

  def validate_permissions
    return if %w(email do_email).include? action_name
    msg = "Permission denied"
    redirect_to without_team_path, :notice => msg if @user.team.nil?
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

  def check_can_send
    msg = 'Reached email limit. Please contact a system administrator.'
    redirect_to '/', :notice => msg unless @user.can_email_team(@team.id)
  end
end
