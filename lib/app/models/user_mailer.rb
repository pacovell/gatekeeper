class UserMailer < ActionMailer::Base
    
  def forgot(user)
    subject    'Password Reset'
    recipients user.email
    from       'WhatsOnHK'
    sent_on    Time.now
    
    body       :url => reset_password_url(:key => user.password_key)
  end
  

end
