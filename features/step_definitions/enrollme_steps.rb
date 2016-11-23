Given /^PENDING: .*$/ do
  pending
end

Given /^I log in as an admin with email "([^"]*)"$/ do | email |
  mock_auth_hash(email)
  click_link "log_in"
end

Given /^I log in as a user with email "([^"]*)"$/ do | email |
  mock_auth_hash(email)
  click_link "log_in"
end

And /^I log out$/ do
  step %Q{I follow "Logout"}
end

When /^I remove "([^"]*)"$/ do | user |
  step %Q{I press "remove_#{user}"}
end

When /^I leave my team$/ do
  step %Q{I press "leave_team"}
end

And /^I join a team with passcode "([^"]*)"$/ do | passcode |
  step %Q{I fill in "team_hash" with "#{passcode}"}
  step %Q{I press "Join"}
end

Given(/^the team with passcode "([^"]*)" is approved with discussion number "([^"]*)"$/) do |passcode, number|
  Team.find_by_passcode(passcode).approve_with_discussion(Discussion.find_by_number(number).id)
end

And /^the team with passcode "([^"]*)" is( not)? submitted$/ do | passcode, negate |
  negate ? Team.find_by_passcode(passcode).update(:submitted => false) : Team.find_by_passcode(passcode).update(:submitted => true)
end

And /^the team with passcode "([^"]*)" is not approved$/ do | passcode |
  Team.find_by_passcode(passcode).update(:approved => false)
end

And /^my team is submitted$/ do
  @team.update(:submitted => true)
end

And /^the team with passcode "([^"]*)" should be (.*)$/ do | passcode, status |
  expect(Team.find_by_passcode(passcode).send(status)).to be_truthy
end

And /^the team with passcode "([^"]*)" should not be (.*)$/ do | passcode, status |
  expect(Team.find_by_passcode(passcode).send(status)).to be_falsy
end


Then /^the "([^"]*)" drop-down should contain the option "([^"]*)"$/ do |dropdown, text|
  expect(page).to have_select(dropdown, :options => [text])
end

# Note: use "0" as team to indicate that this student isn't on a team yet
Given /^the following users exist$/ do |table|
  table.rows.each do |name, email, team_passcode, major, sid|
    next if name == "name" # skipping table header
    @team = Team.where(:passcode => team_passcode).first
    if team_passcode != "0"
      @team = Team.create!(:approved => false, :submitted => false, :passcode => team_passcode) if @team.nil?
      User.create!(:team => @team, :major => major, :name => name, :email => email, :sid => sid)
    else
      User.create!(:team => nil, :major => major, :name => name, :email => email, :sid => sid)
    end
  end
end

Given /^the following discussions exist$/ do |table|
  table.rows.each do |number, time, capacity, seats_open|
    next if number == :number # skipping table header
    Discussion.create!(:number => number.to_i, :time => time, :capacity => capacity.to_i)
  end
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should_not == path_to(page_name)
  else
    assert_not_equal path_to(page_name), current_path
  end
end

Then /^save and open page$/ do
  save_and_open_page
end

Then /^screenshot and open image$/ do
  Capybara::Screenshot.screenshot_and_open_image
end

Then /^I should see the "([^"]*)" button/ do |name|
  should have_button name
end

Then /^I should not see the "([^"]*)" button/ do |name|
  should have_no_button name
end


Given /^the following admins exist$/ do |table|
  table.rows.each do |name, email|
    next if name == "name" # skipping table header
    Admin.create!(:name => name, :email => email)
  end
end

Then /^I should have downloaded a team information file$/ do
   page.response_headers['Content-Disposition'].should include("team_info.csv")
end

Then(/^the team with passcode "([^"]*)" should not exist$/) do |passcode|
  Team.where(:passcode => passcode).length.should eq 0
end

Then(/^the team with ccn "([^"]*)", day "([^"]*)", time "([^"]*)", and capacity "([^"]*)" should exist$/) do |ccn, day, time, capacity|
  Discussion.where(:number => ccn, :day => day, :time => time, :capacity => capacity).length.should eq 1
end