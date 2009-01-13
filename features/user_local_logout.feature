Feature: Logout local user
  In order to logout of the site
  A logged in user
  Should be able to logout

  Scenario: Logout a user who is logged in
		Given the following users:
			| username |
			| user_one |
		And I am logged in as "user_one"
    When I logout
    Then I should be logged out 

  Scenario: Logout an anonymous user
		Given the following users:
			| username |
			| user_one |
		When I logout
		Then I should be logged out
