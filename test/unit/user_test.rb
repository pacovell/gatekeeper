require 'test_helper'

class UserTest < ActiveSupport::TestCase
    
  def test_requirements
    u = User.new
    assert !u.valid?
    
    u.email = "Email"
    u.username = "new_user1"
    u.password = "pw1234"
    u.password_confirmation = "pw1234"
    assert u.valid?, u.errors.full_messages.join(" / ")
  end

  def test_duplicate_email
    u = users(:basic)
    
    u2 = User.new
    u2.email = u.email
    u2.username = "user2"
    u2.password = "pw1234"
    u2.password_confirmation = "pw1234"
    assert !u2.valid?
    
    u2.email = "Email2"
    assert u2.valid?
  end
  
  def test_bad_username
    good_names = %w{ paul abcde thisisaverylongusername}
    bad_names = ["1234startwithnumber", "includes space", "symbol%ss"]

    u = User.new
    u.email = "valid@host.com"
    u.password = "pw1234"
    u.password_confirmation = "pw1234"

    assert !u.valid?
    good_names.each do |name|
      u.username = name
      assert u.valid?, "Test good name: #{name}: " + u.errors.full_messages.join(" / ")
    end
    
    bad_names.each do |name|
      u.username = name
      assert !u.valid?, "Test bad name: #{name}: " + u.errors.full_messages.join(" / ")
    end    
  end
  
  def test_bad_password
    good_password = %w{ morethanfour }
    bad_password = %w{ abc }
  
    u = User.new
    u.email = "valid@host.com"
    u.username = "goodusername"
    
    assert !u.valid?
    good_password.each do |pw|
      u.password = pw
      assert u.valid?, "Test good pw: #{pw}: " + u.errors.full_messages.join(" / ")
    end
    
    bad_password.each do |pw|
      u.password = pw
      assert !u.valid?, "Test bad pw: #{pw}: " + u.errors.full_messages.join(" / ")
    end

  end
  def test_duplicate_username
    u = users(:basic)

    u2 = User.new
    u2.email = "Email2"
    u2.username = u.username
    u2.password = "pw1234"
    u2.password_confirmation = "pw1234"
    assert !u2.valid?
    
    u2.username = "new_user2"
    assert u2.valid?
  end
  
  def test_authenticate
    u = users(:basic)
    
    auth_user = User.authenticate(u.username, "password_basic")
    assert_equal(u, auth_user)
    
    auth_user = User.authenticate(u.username, "badpassword")
    assert_nil auth_user
    
    auth_user = User.authenticate("unknownuser", u.password)
    assert_nil auth_user
    
    auth_user = User.authenticate(nil, nil)
    assert_nil auth_user
  end  
  
  def test_add_and_remove_roles
    u = users(:basic)
    
    r1 = roles(:admin)
    r2 = roles(:editor)
    
    assert_equal 0, u.roles.count
    u.add_role(r1)
    assert_equal 1, u.roles.count
    
    u.add_role(r2)
    assert_equal 2, u.roles.count

    # Don't duplicate entries
    u.add_role(r2)
    assert_equal 2, u.roles.count
    
    assert_equal r1, u.roles.find(r1)
    u.remove_role(r1)
    assert_raise (ActiveRecord::RecordNotFound) {u.roles.find(r1)}
    assert_equal 1, u.roles.count
  end
  
  def test_privilege_check
    u = users(:basic)
    r1 = roles(:admin)
    p1 = privileges(:edit_other_users)
    r1.privileges << p1
    
    assert !u.has_privilege?(p1)
    u.add_role(r1)
    assert u.has_privilege?(p1)
    
    # The admin has all privileges
    r1.privileges.delete(p1)
    assert u.has_privilege?(p1)
    
    u.remove_role(r1)
    assert !u.has_privilege?(p1)
  end

end
