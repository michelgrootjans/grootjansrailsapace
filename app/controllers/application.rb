# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  before_filter :check_authorization

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a09fe6c85f0604471d907b5a59a7c333'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  # pick a unisue cookie name to distinguish our session data from others
  session :session_key => '_rails_space_session_id'
  
  def check_authorization
    authorization_token = cookies[:authorization_token]
    if authorization_token and not logged_in?
      user = User.find_all_by_authorization_token(authorization_token)
      user.login!(session) if user
    end
  end
end
