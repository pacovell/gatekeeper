Given /^the following roles:/ do |role_table|
  role_table.hashes.each do |hash|
    hash['role'].split(/\s*,\s*/).each do |rname|
      role = Role.find_by_tag(rname)
      if !role
        role = Role.new
        role.tag = rname
        role.save!
      end
      if !hash['privileges'].blank?
        hash['privileges'].split(/\s*,\s*/).each do |pname|
          privilege = Privilege.find_by_tag(pname)
          if !privilege
            privilege = Privilege.new
            privilege.tag = pname
            privilege.save!
          end
          role.privileges << privilege
        end
      end
    end
  end
end

Given /^the following users:/ do |user_table|
  user_table.hashes.each do |hash|
    username = hash['username']
    user = User.find_by_username(username)
    if !user
      user = User.new
      user.username = username.strip
      user.password = "pass_" + user.username
      user.password_confirmation = user.password
      user.email = username + "@host.com"
      user.save!
    end
    
    if !hash['roles'].blank?
      hash['roles'].split(/\s*,\s*/).each do |role_name|
        user.add_role(Role.find_by_tag(role_name))
      end
    end
  end
end

Given /^I am logged in as "(.*)"/ do |username|
  assert_not_nil(@current_user = User.find_by_username(username))
  visit login_user_url
  fill_in :username, :with => username
  fill_in :password, :with => "pass_#{username}"
  click_button :login
  response.body.should_not =~ /Invalid/m
  assert_equal @current_user.id, session[:user_id], "Session ID valid"
end

When /^I visit the "(.*)" user page$/ do |page|
  page_map = {'login' => login_user_url,
              'logout' => logout_users_url,
              'forgot password' => forgot_password_url,
              'new' => new_user_url}
  assert_not_nil page_map[page], "Unknown page to visit '#{page}' - update the user steps if necessary"
  visit(page_map[page]) 
end

When /^I visit the "(.*)" user page for "(.*)"$/ do |page, username|
  assert_not_nil(user = User.find_by_username(username), "Couldn't find user")
  url = case page
  when 'edit': edit_user_url(user)
  else
    flunk("Unknown user page to visit '#{page}' - update the user steps if necessary")
  end
    
  visit(url)
end

When /^I fill in the user settings with:$/ do |user_table|
  user_table.hashes.each do |hash|
    hash.each do |key, value|
      fill_in("user_#{key}", :with => value)
    end
  end
end

When /^I logout$/ do
  visit(logout_users_url)
end

When /^I visit the password reset link for (.*)$/ do |name|
  assert_not_nil(user = User.find_by_username(name))
  url = reset_password_url(user.password_key)
  visit(url)
end

When /^I enter a new password "(.*)"$/ do |pw|
  fill_in("user_password", :with => pw)
  fill_in("user_password_confirmation", :with => pw)
  click_button("Save")  
end

Then /^(.*) password is equal to "(.*)"/ do |name, pw|
  user = User.find_by_username(name)
  assert_not_nil user
  assert_equal user, User.authenticate(name, pw)
end

Then /^a reset password email is sent to (.*)$/ do |name|
  user = User.find_by_username(name)
  assert_not_nil user
  Then "an email is sent to #{user.email}"
end

Then /^I should be logged in as "(.*)"$/ do |username|
  assert_not_nil(user = User.find_by_username(username), "Couldn't find user")
  assert_equal user.id, session[:user_id]
end

Then /^I should be logged out$/ do
  assert_nil session[:user_id]
end

Then /^I should see a "(.*)" page error$/ do |error|
  case error.downcase
  when 'not found': assert_response :not_found
  else
    flunk("Invalid error: '#{error}' - you may need to update user_steps")
  end
end