require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @valid_user   = users(:valid_user)
    @invalid_user = users(:invalid_user)
    @error_messages = ActiveRecord::Errors.default_error_messages
  end
	
  def test_user_validity
    assert @valid_user.valid?
  end
	
  def test_user_invalidity
    assert !@invalid_user.valid?
    attributes = [:screen_name, :email, :password]
    attributes.each do |attribute|
      assert @invalid_user.errors.invalid?(attribute)
    end
  end
	
  def test_uniqueness_of_screen_name_and_email
    user_repeat = User.new( :screen_name 	=> @valid_user.screen_name,
      :email				=> @valid_user.email,
      :password			=> @valid_user.password)
    assert !user_repeat.valid?
    assert_equal @error_messages[:taken], user_repeat.errors.on(:screen_name)
    assert_equal @error_messages[:taken], user_repeat.errors.on(:screen_name)
  end
	
  def test_screen_name_minimum_length
    user = @valid_user
    min_length = User::SCREEN_NAME_MIN_LENGTH
		
    #screen name is too short
    user.screen_name = "a" * (min_length - 1)
    assert !user.valid?, "#{user.screen_name} should raise a minimum length error"
    #format the error message based on minimum length
    correct_error_message = sprintf(@error_messages[:too_short], min_length)
    assert_equal correct_error_message, user.errors.on(:screen_name)
		
    #screen name is minimum length
    user.screen_name = "a" * (min_length)
    assert user.valid?, "#{user.screen_name} should be just long enough to pass"
  end
	
  def test_screen_name_maximum_length
    user = @valid_user
    max_length = User::SCREEN_NAME_MAX_LENGTH
		
    #screen name is too short
    user.screen_name = "a" * (max_length + 1)
    assert !user.valid?, "#{user.screen_name} should raise a maximum length error"
    #format the error message based on minimum length
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:screen_name)
		
    #screen name is maximum length
    user.screen_name = "a" * (max_length)
    assert user.valid?, "#{user.screen_name} should be just short enough to pass"
  end
	
  def test_password_minimum_length
    user = @valid_user
    min_length = User::PASSWORD_MIN_LENGTH
		
    #password is too short
    user.password = "a" * (min_length -1)
    assert !user.valid?, "#{user.password} should raise a minimum length error"
    #format the error message based on minimum length
    correct_error_message = sprintf(@error_messages[:too_short], min_length)
    assert_equal correct_error_message, user.errors.on(:password)
		
    #password is minimum length
    user.password = "a" * min_length
    assert user.valid?, "#{user.password} should be just long enough to pass"
  end
	
  def test_password_maximum_length
    user = @valid_user
    max_length = User::PASSWORD_MAX_LENGTH
		
    #password is too long
    user.password = "a" * (max_length + 1)
    assert !user.valid?, "#{user.password} should raise a maximum length error"
    #format the error message based on maximum length
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:password)
		
    #password is maximum length
    user.password = "a" * max_length
    assert user.valid?, "#{user.password} should be short enough to pass"
  end
	
  def test_email_maximum_length
    user = @valid_user
    max_length = User::EMAIL_MAX_LENGTH
    original_email = user.email
		
    #password is too long
    user.email = "a" * (max_length + 1 - original_email.length) + original_email
    assert !user.valid?, "#{user.email} should raise a maximum length error"
    #format the error message based on maximum length
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:email)
		
    #password is maximum length
    user.email = "a" * (max_length - original_email.length) + original_email
    assert user.valid?, "#{user.email} should be short enough to pass"
  end
	
  def test_email_with_valid_examples
    user = @valid_user
    valid_endings = %w(com org net edu es jp info be)
    valid_emails = valid_endings.collect do |ending|
      user.email = "foo.bar_1-9@baz-quux0.example.#{ending}"
      assert user.valid?, "#{user.email} should be a valid email address"
    end
  end
	
  def test_email_with_invalid_examples
    user = @valid_user
    invalid_email = %w(foobar@example.c @example.com f@com foo@bar..com
		                   foobar@example.infod foobar.example.com
											 foo,@example.com foo@example,com)
    invalid_email.each do |email|
      user.email = email
      assert !user.valid?, "#{user.email} should not be a valid email address"
      assert_equal "must be a valid email address", user.errors.on(:email)
    end
  end
	
  def test_screen_name_with_valid_examples
    user = @valid_user
    valid_screen_names = %w(aure michael web_20)
    valid_screen_names.each do |screen_name|
      user.screen_name = screen_name
      assert user.valid?, "#{user.screen_name} should be a valid screen name"
    end
  end
	
  def test_screen_name_with_invalid_examples
    user = @valid_user
    invalid_screen_names = %w(rails/rocks web2.0 javascript:something)
    invalid_screen_names.each do |screen_name|
      user.screen_name = screen_name
      assert !user.valid?, "#{user.screen_name} should not be a valid screen name"
    end
  end
	
	
end
