module Gatekeeper #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions
      def gatekeeper
        # Named routes must come before the resource mapping
        with_options :controller => 'users' do |map|
          map.named_route('login_user', 'users/login', :action => 'login')
          map.named_route('forgot_password', 'users/forgot', :action => 'forgot')
          map.named_route('reset_password', 'users/reset/:key', :action => 'reset')
        end
        resources(:users, :collection => { :logout => :get })
      end
    end
  end
end

