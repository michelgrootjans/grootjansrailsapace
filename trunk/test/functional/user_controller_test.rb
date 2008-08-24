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
	
	def test_registration_success
		post :register, :user => {	:screen_name	=> "new_screen_name",
																:email				=> "valid@example.com",
																:password			=> "long_enough_password" }
		
		#test the assignment of the user
		user = assigns(:user)
		assert_not_nil user
		
		#test new user in database
		new_user = User.find_by_screen_name_and_password(user.screen_name, user.password)
		assert_equal new_user, user
		
		#test flash and redirection
		assert_equal "User #{new_user.screen_name} created!", flash[:notice]
		assert_redirected_to :action => "index"
	end
	
	def test_registration_failure
		post :register, :user => {	:screen_name	=> "aa/noyes",
																:email				=> "anoyesatexample.com",
																:password			=> "sun" }
		assert_response :success
		assert_template "register"
		
		#test display of error messages
		assert_tag "div", :attributes => {	:id			=> "errorExplanation",
																				:class	=> "errorExplanation" }
		#assert that each form field has an error displayed
		assert_tag "li", :content => /Screen name/
		assert_tag "li", :content => /Email/
		assert_tag "li", :content => /Password/
		
		#test to see that the input fields are being wrapped with the correct div
		error_div = { :tag => "div", :attributes => { :class => "fieldWithErrors" }}
		assert_tag "input",	:attributes	=>	{	:name => "user[screen_name]",
																					:value => "aa/noyes"},
												:parent => error_div
		assert_tag "input", :attributes => 	{ :name => "user[email]",
																					:value => "anoyesatexample.com"},
												:parent => error_div
		assert_tag "input", :attributes => {	:name => "user[password]",
																					:value => "sun"},
												:parent => error_div
	end

end
