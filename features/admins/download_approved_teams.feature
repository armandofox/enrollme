Feature: get a csv with the information of all approved teams

  As an administrator
  So that I can see all approved students and teams
  I want to download all that information from my home page
  
  Background:
    Given the following users exist
     | name  |       email                    |team_passcode | major           | sid  | waitlisted |
     | Sahai | eecs666@hotmail.com            | penguindrool | EECS            | 000  | Yes |
     | Saha2 | eecs667@hotmail.com            | penguindrool | EECS            | 001  | Yes |
     | Saha3 | eecs668@hotmail.com            | penguindrool | EECS            | 002  | Yes |
     | Saha4 | eecs669@hotmail.com            | penguindrool | EECS            | 003  | Yes |
  	 | Jorge | legueoflegends667@hotmail.com  | penguindrool | Football Player | 999  | Yes |
  	And the following admins exist
  	 | name  | email                  |
  	 | Bob   | supreme_ruler@aol.com  |
    And the following discussions exist
   	 | number  | time         |  capacity |
   	 | 54321   | Tues, 3pm    |  25       |
  	And I am on the login page
    And I log in as an admin with email "supreme_ruler@aol.com"
  	And the team with passcode "penguindrool" is approved with discussion number "54321"

  Scenario: An admin successfully downloads approved team information
    Given I follow "Download this data"
  	Then I should have downloaded a team information file
    