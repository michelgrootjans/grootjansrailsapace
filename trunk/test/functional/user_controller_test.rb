require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

#Re-raise errors caught by the controller
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase

	def test_registration_page
		get :register
		title = assigns(:title)
		assert_equal "Register", title
		assert_response :success
		assert_template "register"
		
		#Test the form and all of its tags
		assert_tag "form",	:attributes	=>	{	:action => "/user/register",
																					:method => "post"}
		assert_tag "input",	:attributes	=>	{	:name => "user[screen_name]",
																					:type => "text",
																					:size => User::SCREEN_NAME_SIZE,
																					:maxlength => User::SCREEN_NAME_MAX_LENGTH}
		assert_tag "input", :attributes => 	{ :name => "user[email]",
																					:type => "text",
																					:size => User::EMAIL_SIZE,
																					:maxlength => User::EMAIL_MAX_LENGTH}
		assert_tag "input", :attributes => {	:name => "user[password]",
																					:type => "password",
																					:size => User::PASSWORD_SIZE,
																					:maxlength => User::PASSWORD_MAX_LENGTH}
		assert_tag "input", :attributes => {	:type  => "submit",
																					:value => "Register!"}
	end

end
