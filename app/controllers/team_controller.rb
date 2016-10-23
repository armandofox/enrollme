class TeamController < ApplicationController
    
  def index
    @user_id = session[:user_id]
    return redirect_to login_path if @user_id.nil?
    
    @user = User.find(@user_id)
    return redirect_to without_team_path, :notice => "Your team does not exist" if @user.team.nil?

    return redirect_to team_path(:id => @user.team.id)
  end
  
  def show
    @user_id = session[:user_id]
    return redirect_to login_path if @user_id.nil?

    @user = User.find(@user_id)
    return redirect_to without_team_path, :notice => "Your team does not exist" if @user.team.nil?

    @team = Team.where(:id => params[:id]).first
    return redirect_to '/', notice: "Cannot access this team" if @team.nil?
    return redirect_to team_path(:id => @user.team.id), notice: "Cannot access this team" if @user.team != @team

    render "team"
  end
  
  def leave
    @user = User.find(session[:user_id])
    @team = @user.team
    @team.users.delete(@user)
    @user.team = nil
    return redirect_to without_team_path
  end
  
  def update
  end
  
  # TODO: edit users in the team page (for now, it's just text)
  # but we need to change that to a button + add some kind of form?
  # what were we going to do with that anyway, add/delete?
  # we could just have a "remove" button and some kind of 
  # "Are you sure?" thing--can ask MDS what he wants idk
end