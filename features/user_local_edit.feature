Feature: Edit local user
  In order to update / modify user information
  A properly authorized user
  Should be able to edit self and other users

	Scenario: Unauthorized user edit others account
		Given the following users:
			| username |
			| user_one |
			| user_two |
		And I am logged in as "user_one"
		When I visit the "edit" user page for "user_two"
		Then I should see a "Not Found" page error

	Scenario Outline: Authorized account editing
		Given the following roles:
			| role     | privileges       |
			| admin    |                  |
			| manager  | edit_other_users |
		And the following users:
			| username   | roles            |
			| user_one   | admin            |
			| user_two   | manager          |
			| user_three |	                |
		And I am logged in as "<user>"
		When I visit the "edit" user page for "<target>"
		And I fill in the user settings with:
			| email          | password          | password_confirmation  |
			| test@test.com  | pwtest            | pwtest                 | 
		And I press "Save"
		Then I should see the notice "User updated"
		
	Examples:
		| user       | target     |
		| user_one   | user_three |
		| user_two   | user_three |
		| user_three | user_three |
