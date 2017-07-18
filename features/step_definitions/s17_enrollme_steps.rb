# Declarative step to populate DB with teams

Given /a listing of teams with the following information/ do |teams_table|
  pending
  # @team_listing = teams_table
  # teams_table.hashes.each do |team|
  #  Team.create!
  # end
end

Given /I? type "(.*)"/ do |text|
  pending
end

Given /I? click the following fields: (.*)/ do |fields|
  pending
end

Given /I? upload the image (.*)/ do |image|
  pending
end

Then /I? should see the image (.*)/ do |image|
  pending
end

Then /I? should see the file (.*)/ do |file|
  pending
end



################ Team Listing Step Defs ####################


Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  first = page.body.index(e1)
  second = page.body.index(e2)
  expect(first < second)
end

Given /I? check the (un?)declared filter/ do |undeclared|
  if undeclared
    check("undeclared") # name of checkbox depends on what you tag it in html file, so tag accordingly
  else
    check("declared")
  end
end

Given /I press on row \d*/ do |row_num|
  # Click on the team in row #{row_num} of the table
  pending
end

Then /I visit the team profile of the team on row \d*/ do |row_num|
  # @team_id =  # Set instance variable @team_id to equal the id of the team in that row on the table, then redirect to the url of that team's profile
  pending
end

Given /I? press the (.*) heading, while (.*)/ do |heading, prev_order|
  # Check if the heading was in descending, ascending, or unordered before somehow;
  # Perhaps split this step into 2 steps: Given I press the (.*) heading, And the heading is in (.*) order
  pending
end

Given /I? press ("[^\"]*" ) team/ do
  # Use web_steps "press" step to press the button
  # Set instance variable to track the current team_idS
  # Set instance variable to track the current state of the team request variable for user for particular team
  # which we will use in following 3 step defs
  pending
end

Then /I am linked to a page to send a join team message/ do
  # Check that you are linked to page to send join team message for the corresponding team
  pending
end

Then /I cancel my join "request"/ do
  # check that current request to selected team is no longer join
  pending
end

And /it displays ("You have left your team")/ do |message|
  # Check that the message is flashed
  pending
end