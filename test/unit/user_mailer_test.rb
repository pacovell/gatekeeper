require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
    
  test "forgot" do
    user = users(:basic)
    user.set_password_key!
    
    response = UserMailer.create_forgot(user)
    
    assert_equal("Password Reset" , response.subject)
    assert_equal(user.email, response.to[0])
    assert_match(/reset your password/, response.body)
  end

end
