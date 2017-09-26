Feature: Table for finding and joining teams
  As a user
  In order to find an open team that suits my preferences
  I want to see all the currently open teams and be able to view, sort, and join/leave them
  
  Background:
    Given the following users exist
      |   name    |       email                       | team      | major             |       sid         |  waitlisted |
      | Bob       |    bobjones0@berkeley.edu         | passcode1 | Slavic Studies    | 824               | true |
      | Bob1      |    bobjones1@berkeley.edu         | passcode1 | Slavic Studies    | 825               | true |
      | Bob2      |    bobjones2@berkeley.edu         | passcode1 | Slavic Studies    | 826               | true |
      | Bob3      |    bobjones3@berkeley.edu         | passcode1 | Slavic Studies    | 827               | true |
      | Bob4      |    bobjones4@berkeley.edu         | passcode1 | Slavic Studies    | 828               | true |
      | Sahai     |    xxx@berkeley.edu         | passcode2 | Slav1c Studies    | 830               | true |
      | Saha2     |    xx2@berkeley.edu         | passcode2 | Slav1c Studies    | 831               | true |
      | Saha3     |    xx3@berkeley.edu         | passcode2 | Slav1c Studies    | 832               | true |
      | Saha4     |    xx4@berkeley.edu         | passcode2 | Slav1c Studies    | 833               | true |
      | Jorge     |    legueoflegends667@hotmail.com  | passcode3 | Football Player   | 999               | false |
    
    And team "passcode1" has 0 pending requests
    And team "passcode2" has 2 pending requests
    And team "passcode3" has 1 pending request
    
    And team "passcode1" is declared
    And team "passcode2" is declared
    And team "passcode3" is not declared
    
    And I am on the home page
    Then I should not see "Team List"
    
    And I am on the new_user page
    And I fill in "Name" with "Oski"
    And I fill in "Email" with "oskibear@berkeley.edu"
    And I fill in "Sid" with "12345678"
    And I select "DECLARED CS/EECS Major" from "major"
    And I choose "user_waitlisted_true"
    And I press "Sign Up"
    And I follow "Team List"
    And I should see "Group Members"
    And I should see "Number of Members"
    And I should see "Number of Pending Requests"
    And I should see "All Waitlisted?"
    And I should see "Request"
  
  # Index should have teams sorted in descending order based on number_of_members
  Scenario: User opens up table of teams page for first time, and teams should be sorted in descending order by default
    Then I should see "Bob" before "Sahai"
    And I should see "Sahai" before "Jorge"
  
  # Sort listing by number of group members in ascending order, when it was in descending order before
  Scenario: A user wants to sort teams by the number of group members, while it is in descending order
    Given I follow "Number of Members"
    # Should change to ascending order and sort
    Then I should see "Jorge" before "Sahai"
    And I should see "Sahai" before "Bob"
    
  # Sort listing by number of pending requests in descending order, when it was unordered before
  Scenario: A user wants to sort teams by the number of pending requests, while it is unordered
    Given I follow "Number of Pending Requests"
    # Should change to descending order and sort
    Then I should see "Sahai" before "Jorge"
    And I should see "Jorge" before "Bob"
    
  # Sort listing by number of pending requests in ascending order, when it was in descending order before
  Scenario: A user wants to sort teams by the number of pending requests, while it is in descending order
    Given I follow "Number of Pending Requests"
    And I follow "Number of Pending Requests"
    # Should change to ascending order and sort
    Then I should see "Bob" before "Jorge"
    And I should see "Jorge" before "Sahai"
    
  # Filter listing by showing only teams where all team members are waitlisted
  Scenario: A user wants to filter teams based on whether all team members are waitlisted
    Given I check "waitlisted_yes"
    And I press "Refresh"
    Then I should see "Bob"
    And I should see "Sahai"
    And I should not see "Jorge"
  
  # Filter listing by showing only teams where all team members are not waitlisted
  Scenario: A user wants to only see teams where all members are not waitlisted
    Given I check "waitlisted_no"
    And I press "Refresh"
    Then I should not see "Bob"
    And I should not see "Sahai"
    And I should see "Jorge"
  