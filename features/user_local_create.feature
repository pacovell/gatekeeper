Feature: Create local user
  In order to create a user
  An anonymous user
  Should be able to create a new user

  Scenario: Create user
		Given I visit the "new" user page
		When I fill in the user settings with:
			| username  | password          | password_confirmation | email             |
			| user_one  | password_user_one | password_user_one     | user_one@host.com | 
		And I press "Create"
		Then I should be logged in as "user_one"