Feature: Login local user
  In order to login to the site
  A local user
  Should be able to login

	Scenario: Login with correct username, password
		Given the following users:
			| username |
			| user_one |
		And I visit the "login" user page
		When I fill in "username" with "user_one"
		And I fill in "password" with "pass_user_one"
		And I press "Login"
		Then I should not see "Invalid"
		And I should be logged in as "user_one"
		
	Scenario Outline: Login with incorrect username, password
		Given the following users:
			| username |
			| user_one |
		And I visit the "login" user page
		When I fill in "username" with "<username>"
		And I fill in "password" with "<password>"
		And I press "Login"
		Then I should see "Invalid"
		And I should be logged out
		
	Examples:
		| username | password     |
		| user_two | incorrect_pw |
		| user_one | incorrect_pw |
		| user_two | password_one |
		| empty    | password_one |
		| user_one | empty        |
		