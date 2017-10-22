Feature: admin can view Group Information

  As an administrator
  So that I can see which teams are paired as a group
  I want to view all pairs of groups
  
  Background:
    Given the following groups exist
     | team1_id |       team2_id    |discussion_id  |
     | 1        | 2                 | 112111        |
     | 3        | 4                 | 112121        |
     | 6        | 5                 | 112113        |

  	And the following admins exist
  	 | name  | email                  |
  	 | Bob   | supreme_ruler@aol.com  |
    And the following discussions exist
   	 | number  | time         |  capacity |
   	 | 54321   | Tues, 3pm    |  25       |
    

  Scenario: An admin accesses a View Groups page
    Given I am on the login page
    And I log in as an admin with email "supreme_ruler@aol.com"
    When I press "View Groups"
    Then I should see "112111"
    And I should see "112121"
    And I should see "112113"