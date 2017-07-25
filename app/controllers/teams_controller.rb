class TeamsController < ApplicationController

  before_filter :set_user, :set_team
  before_filter :set_permissions, :except => ['index', 'profile']
  before_filter :check_approved, :only => ['submit', 'unsubmit', 'edit']


  def index
    sort = params[:sort] || session[:sort] || 'default'
    case sort
    when 'default'
      ordering, @num_members_header = {:users_count => :desc}, 'hilite'
    when 'users_count'
      if params[:sort]
        if session[:ordering]["users_count"] == "desc"
          ordering,@num_members_header = {:users_count => :asc}, 'hilite'
        else
          ordering,@num_members_header = {:users_count => :desc}, 'hilite'
        end
      end
    when 'pending_requests'
      if session[:ordering]["pending_requests"] == "desc"
        ordering,@pending_requests_header = {:pending_requests => :asc}, 'hilite'
      else
        ordering,@pending_requests_header = {:pending_requests => :desc}, 'hilite'
      end
    end
    @all_majors = Team.all_declared
    @selected_majors = params[:major] || session[:major] || {}
    
    if @selected_majors == {}
      @selected_majors = Hash[@all_majors.map {|m| [m, m]}]
    end
    
    if params[:sort] != session[:sort] or params[:major] != session[:major]
      session[:sort] = sort
      session[:major] = @selected_majors
      redirect_to :sort => sort, :major => @selected_majors and return
    end
    
    session[:ordering] = ordering
    # flash[:notice] = "all_majors is #{@all_majors}, and selected_majors is #{@selected_majors}, and selected_majors.keys is #{@selected_majors.keys}"
    #@teams = Team.where(declared: @selected_majors).order(ordering) # this line is bugged?
    @teams = Team.order(ordering)
    
  end
  
  def profile
    @team = Team.find_by_id(params[:id])
    # @discussions = Discussion.valid_discs_for(@team)
    # if @team.submitted and !(@team.approved)
    #   @s = Submission.find(@team.submission_id)
    #   @d1 = Discussion.find(@s.disc1id)
    #   @d2 = Discussion.find_by_id(@s.disc2id)
    #   @d3 = Discussion.find_by_id(@s.disc3id)
    # end
  end


  def update
  
  end
  
  #This is from past semester
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




  private

  def set_user
    if session[:is_admin]
      @user = Admin.find(session[:user_id])
    else
      @user = User.find(session[:user_id])
      # Don't redirect it because user without team should still be able to view team list
      # redirect_to without_team_path, :notice => "Permission denied" if @user.team.nil?
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