Given /^the email queue is empty$/ do
	ActionMailer::Base.deliveries.clear
end

Then /^an email is sent to (.*)$/ do |address|
  emails = ActionMailer::Base.deliveries
  assert_equal 1, emails.length
  email = emails.first
  assert_equal address, email.to[0]
end  

Then /^no email is sent$/ do
  emails = ActionMailer::Base.deliveries
  assert_equal 0, emails.length, emails.to_yaml
end
