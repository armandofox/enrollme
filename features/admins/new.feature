Feature: Create an admin account
  As an admin
  In order to spread my workload
  I want to add another person as an admin
  
  Background:
    Given the following admins exist
     | name  | email                  |
  	 | Bob   | supreme_ruler@aol.com  |
  	And I am on the login page
  	And I log in as an admin with email "supreme_ruler@aol.com"

  Scenario: An admin successfully adds another admin
    Given I follow "Register New Admin"
    And I fill in "Name" with "Bob Clone"
    And I fill in "Email" with "ruler_clone@aol.com"
    And I press "Create"
    Then I log out
    When I log in as an admin with email "ruler_clone@aol.com"
    Then I should see "Welcome Back, Bob Clone!"
    
