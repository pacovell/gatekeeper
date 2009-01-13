require 'test_helper'
require 'users_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @basic = users(:basic)
    @basic_2 = users(:second_basic)
    @admin = users(:admin)
    @admin.add_role("admin")
  end
  
  test "create new user" do
    get :new
    assert_response :success
    assert_select "form[action=#{users_path}]" do
      %w{ username email password password_confirmation }.each do |field|
        assert_select "input[name='user[#{field}]']"
      end
    end
    
    post :create, :user => {:username => "user1", :email => "user1@user.com", :password => "password1", :password_confirmation => "password1"}
    assert_response :redirect
    assert_equal "User created", flash[:notice]
    assert_not_nil User.authenticate("user1", "password1"), "User not created"
  end
  
  test "show user" do
    authorized_actors = [@basic, @admin]
    unauthorized_actors = [nil, @basic_2]
    
    authorized_actors.each do |actor|  
      make_authorized_request(actor, @basic, :get, :show)
      assert_response :success, "Auth: #{actor.username}"
    end
    
    unauthorized_actors.each do |actor|  
      make_authorized_request(actor, @basic, :get, :show)
      assert_response :not_found, "Unauth: #{actor.nil? ? "Nil" : actor.username}"
    end
  end
  
  test "edit user" do
    authorized_actors = [@basic, @admin]
    unauthorized_actors = [nil, @basic_2]
    
    authorized_actors.each do |actor|  
      make_authorized_request(actor, @basic, :get, :edit)
      assert_response :success
      assert_select "form[action=#{user_path(@basic)}]" do
        %w{ email password password_confirmation }.each do |field|
          assert_select "input[name='user[#{field}]']"
        end
      end
    end
    
    unauthorized_actors.each do |actor|  
      make_authorized_request(actor, @basic, :get, :edit)
      assert_response :not_found
    end
  end 
  
  test "update email" do
    authorized_actors = [@basic, @admin]
    unauthorized_actors = [nil, @basic_2]
    original_email = @basic.email
    
    authorized_actors.each do |actor|  
      @basic.update_attribute(:email, original_email)  # Reload each time
      
      make_authorized_request(actor, @basic, :post, :update, :user => {:email => "update_email"})
      assert_redirected_to user_path(@basic)
      # Something broken in loops for flash[:notice]?      
      #assert_equal "User updated", flash[:notice], "Auth: #{actor.username}"
      @basic.reload
      assert_equal "update_email", @basic.email, "User email not updated"
    end
    
    unauthorized_actors.each do |actor|  
      @basic.update_attribute(:email, original_email)  # Reload each time
      make_authorized_request(actor, @basic, :post, :update, :user => {:email => "update_email"})
      assert_response :not_found
      @basic.reload
      assert_equal users(:basic).email, @basic.email, "User email updated when it shouldn't be"
    end
  end
  
  test "update password" do
    original_pw = "password_basic"    
    authorized_actors = [@basic, @admin]
    unauthorized_actors = [nil, @basic_2]
    
    authorized_actors.each do |actor|  
      # Reload each time
      @basic.password = original_pw
      @basic.save!

      make_authorized_request(actor, @basic, :post, :update, :user => {:password => "pw_update", :password_confirmation => "pw_update"})
      
      assert_redirected_to user_path(@basic)
      # Something broken in loops for flash[:notice]?
      #assert_equal "User updated", flash[:notice], "Auth: #{actor.username}"
      
      @basic.reload
      assert_equal @basic, User.authenticate(@basic.username, "pw_update"), "User authenticate with new password failed"
    end
    
    unauthorized_actors.each do |actor|  
      # Reload each time
      @basic.password = original_pw
      @basic.save!
      
      make_authorized_request(actor, @basic, :post, :update, :user => {:password => "pw_update", :password_confirmation => "pw_update"})
      assert_response :not_found
      @basic.reload
      assert_equal @basic, User.authenticate(@basic.username, original_pw), "User authenticate with original password failed"
    end
  end
  
  test "get login form" do 
    get :login
    assert_response :success
    assert_select "form[action=#{login_user_path}]" do
      %w{ username password }.each do |field|
        assert_select "input[name='#{field}']"
      end
    end
  end  
  
  test "user login with good password" do
    user = users(:basic)
    post :login, :username => user.username, :password => "password_basic"
    assert_response :redirect
    assert_equal user.id, session[:user_id], "Did not assign proper user"
  end

  test "user login with bad password" do
    user = users(:basic)
    post :login, :username => user.username, :password => "nottherightpw"
    assert_redirected_to login_user_url
    assert_nil session[:user_id], "User assigned even with wrong password"
    assert_equal "Invalid username or password", flash[:notice]
  end
  
  test "user login with bad username" do
    user = users(:basic)
    post :login, :username => "badusername", :password => user.password
    assert_redirected_to login_user_url
    assert_nil session[:user_id], "User assigned even with wrong username"
    assert_equal "Invalid username or password", flash[:notice]
  end
  
  test "user login with empty username" do
    user = users(:basic)
    post :login, :password => user.password
    assert_redirected_to login_user_url
    assert_nil session[:user_id], "User assigned even with empty username"
    assert_equal "Invalid username or password", flash[:notice]
  end    
      
  test "user login with empty password" do
    user = users(:basic)
    post :login, :username => user.username
    assert_redirected_to login_user_url
    assert_nil session[:user_id], "User assigned even with empty password"
    assert_equal "Invalid username or password", flash[:notice]
  end    
  
  test "user logout" do
    post :logout, nil, {:user_id => users(:basic).id}
    assert_response :redirect
    assert_nil session[:user_id]
    assert_equal "Logged out", flash[:notice]
  end
  
  test "user forgot password page" do
    get :forgot
    assert_response :success
    assert_select "form[action=#{forgot_password_path}]" do
      %w{ username_or_email }.each do |field|
        assert_select "input[name='#{field}']"
      end
    end
  end
  
  test "user requests reset password" do
    user = users(:basic)
    valid_attempts = [user.username, user.email]
    
    valid_attempts.each do |attempt|
      user.clear_password_key!

      # Clear email testing array
      emails = ActionMailer::Base.deliveries
      emails.clear
      
      post :forgot, :username_or_email => attempt
      assert_redirected_to forgot_password_path
      
      # Verify email sent
      assert_equal(1, emails.size)
      email = emails.first
      assert_equal(user.email, email.to[0])
      assert_equal("Password Reset", email.subject)
      
      user.reload
      assert_not_nil user.password_key
    end
  end
  
  test "user requests reset password page with key" do
    user = users(:basic)
    key = "ABCDE"
    set_password_reset_key(user, key)
    
    get :reset, :key => key
    assert_response :success
    assert user.id, session[:user_id]
    assert_select "form[action=#{reset_password_path}]" do
      %w{ password password_confirmation }.each do |field|
        assert_select "input[name='user[#{field}]']"
      end
    end  
  end
  
  test "user submits new password with key" do
    user = users(:basic)
    key = "ABCDE"
    new_pw = "reset_password"
    set_password_reset_key(user, key)
      
    put :reset, :key => key, :user => {:password => new_pw, :password_confirmation => new_pw}
    assert_redirected_to user_path(user)
    assert user.id, session[:user_id]
    
    # Test that the new password works for authentication
    user.reload
    assert_equal user, User.authenticate(user.username, new_pw)
    # Test that the password key has been deleted
    assert_nil user.password_key
  end  
  
  test "user requests reset password with expired key" do
    user = users(:basic)
    key = "ABCDE"
    set_password_reset_key(user, key, 10.days.ago)

    get :reset, :key => key
    assert_response :redirect
    assert_equal "Request is not valid - perhaps it has expired?  Please try again.", flash[:notice]
  end
  
  test "user submits new password with expired key" do
    user = users(:basic)
    key = "ABCDE"
    new_pw = "reset_password"
    set_password_reset_key(user, key, 10.days.ago)
    
    post :reset, :key => key, :user => {:password => new_pw, :password_confirmation => new_pw}
    
    assert_response :redirect
    assert_equal "Request is not valid - perhaps it has expired?  Please try again.", flash[:notice]
  end

  protected
  
  def make_authorized_request(actor, target, request_type, action, options = {})
    session_hash = {}
    session_hash = {:user_id => actor.id} if actor
        
    send(request_type, action, options.merge({:id => target.id}), session_hash)
  end
  
  def set_password_reset_key(user, key, created_at = nil)
    user.password_key = key
    user.password_key_created_at = (created_at || 1.minute.ago)
    user.save!
  end
  
end
