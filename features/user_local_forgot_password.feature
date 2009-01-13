Feature: Local user forgets password
  In order to reset a forgotten password
  A normal user
  Should be able to request the password to be reset

	Scenario: User requests password to be reset
		Given the following users:
			| username |
			| user_one |
		And the email queue is empty
		When I visit the "forgot password" user page
		And I fill in "username_or_email" with "user_one"
		And I press "Submit"
		Then I should see "Please check your email for instructions to proceed"
		And a reset password email is sent to user_one
		When I visit the password reset link for user_one
		And I enter a new password "reset_pw"
		Then user_one password is equal to "reset_pw"
	
	Scenario: User requests password to be reset with wrong username
		Given the following users:
			| username |
			| user_one |
		And the email queue is empty
		When I visit the "forgot password" user page
		And I fill in "username_or_email" with "user_two"
		And I press "Submit"
		Then I should see "Please check your email for instructions to proceed"
		And no email is sent