
class TeamController < ApplicationController
  

  
  before_filter :set_user, :set_team, :except => ['list', 'profile']
  before_filter :set_permissions, :except => ['list', 'profile']
  before_filter :check_approved, :only => ['submit', 'unsubmit', 'edit']
  
  
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
    AdminMailer.send_look_at_submission
    
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
  
  def list
    search = params[:search] || session[:search] || ''
    sort = params[:sort] || session[:sort] || 'default'
    @waitlist_filter = params[:waitlisted] || session[:waitlisted] || [true, false]
    to_sort = params[:to_sort] || 'true'
    
    if to_sort == 'true'
      case sort
      when 'default'
        ordering, @users_count_header = {:users_count => :desc}, 'hilite'
        session[:ordering] = ordering
      when 'users_count'
        if session[:ordering]["users_count"] == "desc"
          ordering,@users_count_header = {:users_count => :asc}, 'hilite'
        else
          ordering,@users_count_header = {:users_count => :desc}, 'hilite'
        end
        session[:ordering] = ordering
      when 'pending_requests'
        if session[:ordering]["pending_requests"] == "desc"
          ordering,@pending_requests_header = {:pending_requests => :asc}, 'hilite'
        else
          ordering,@pending_requests_header = {:pending_requests => :desc}, 'hilite'
        end
        session[:ordering] = ordering
      end
    else
      ordering = session[:ordering]
    end
    
    
    if params[:sort] != session[:sort] or params[:waitlisted] != session[:waitlisted] or params[:search] != session[:search]
      session[:sort] = sort
      session[:waitlisted] = @waitlist_filter
      session[:search] = search
      redirect_to :sort => sort, :waitlisted => @waitlist_filter, :search => search, :to_sort => false and return
    end
    
    filter = []
    @waitlist_filter. each do |w|
      if (w == 'false') or (w == false)
        filter << false
      elsif (w == 'true') or (w == true)
        filter << true
      end
    end
    
    #.where(waitlisted: @waitlist_filter)
    if search != ''
      @teams = Team.joins(:users).where("users.name LIKE ?", "%#{search}%").order(ordering)
    else
      @teams = Team.where(waitlisted: filter).order(ordering)
    end
  end

  def profile
    @team = Team.find_by_id(params[:id])
    @users_name_arr = @team.getMembersNamesArray
    @users_time_arr = @team.getMembersTimeCommitmentArray
    @users_bio_arr = @team.getMembersBioArray
    @users_exp_arr = @team.getMembersExperiencesArray
    @users_fb_arr = @team.getMembersFacebookArray
    @users_lk_arr =@team.getMembersLinkedinArray
    @users_email_arr = @team.getMembersEmailsArray
    @users_pic_arr = @team.getMembersPicsArray

    # @discussions = Discussion.valid_discs_for(@team)
    # if @team.submitted and !(@team.approved)
    #   @s = Submission.find(@team.submission_id)
    #   @d1 = Discussion.find(@s.disc1id)
    #   @d2 = Discussion.find_by_id(@s.disc2id)
    #   @d3 = Discussion.find_by_id(@s.disc3id)
    # end
  end
  private
  
  def set_user
    if session[:is_admin]
      @user = Admin.find(session[:user_id])
    elsif session[:user_id]
      @user = User.find(session[:user_id])
      redirect_to without_team_path, :notice => "Permission denied" if @user.team.nil?
    else
      redirect_to '/', :notice => "Please log in"
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