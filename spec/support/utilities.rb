def full_title(page_title)
	base_title = "Ruby on Rails Tutorial Sample App"
	if page_title.empty?
		base_title
	else
		"#{base_title} | #{page_title}"
	end
end

def fill_sign_in(user)
	fill_in "Email", 	with: user.email
	fill_in "Password", with: user.password
	click_button "Sign in"
end


def valid_user_update(user)
	fill_in "Name", 	with: new_name
	fill_in "Email", 	with: new_email
	fill_in "Password", with: user.password
	fill_in "Confirm Password", with: user.password
	click_button "Save changes"
end

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end


RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-error', text: message)
	end
end
