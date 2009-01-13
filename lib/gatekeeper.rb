# Gatekeeper
%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  # Remove from load_once_paths so that they are reloaded (development tool TODO remove)
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.view_paths.unshift File.join(File.dirname(__FILE__), 'app', 'views')
ActionMailer::Base.view_paths.unshift File.join(File.dirname(__FILE__), 'app', 'views')

class ActionController::Base
  before_filter :load_current_user
  
  protected
  
  def load_current_user
    @current_user = nil
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end
  
end