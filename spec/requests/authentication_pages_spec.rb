require 'spec_helper'

describe "Authentication" do

	subject { page }		

	describe "signin page" do
		before { visit signin_path }

		it { should have_selector('h1', text: 'Sign in') }
		it { should have_selector('title', text: 'Sign in') }
	end

	describe "signin" do
		before { visit signin_path }

		describe "with invalid credentials" do
			before { click_button "Sign in" }

			it { should have_selector('title', text: 'Sign in') }
			it { should have_error_message('Invalid') }
			it { should_not have_link('Profile') }
			it { should_not have_link('Settings') }
			
			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end


		describe "with valid credentials" do
			let (:user) { FactoryGirl.create(:user) }
			# valid_signin is a helper method -> utilities.rb
			before { sign_in user }

			it { should have_selector('title', text: user.name) }

			it { should have_link('Users', href: users_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }
			
			it { should_not have_link('Sign in', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in') }
			end

			describe "visiting Users#new page" do
				before { visit signup_path }
				it { should have_selector('title', text: full_title('')) }
			end

			describe "submitting a POST request to Users#create action" do
				before { post users_path(user) }
				specify { response.should redirect_to(root_path) }
			end

		end

	end

	describe "authorization" do

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "in the Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "submitting to the update action" do
					before { put user_path(user) }
					specify { response.should redirect_to(signin_path) }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('title', text: full_title('Sign in')) }
				end
			end

			describe "in the Microposts controller" do

				describe "submitting to the create action" do
					before { post microposts_path }
					specify { response.should redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					
					let(:micropost) { FactoryGirl.create(:micropost) }

					before { delete micropost_path(micropost) }

					specify { response.should redirect_to(signin_path) }
				end
			end

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_sign_in user
				end

				describe "after signing in" do

					it "should render the desired protected page" do
						page.should have_selector('title', text: 'Edit user')
					end

					describe "when signing in again" do
						before { sign_in user }

						it "should render the default (profile) page" do
							page.should have_selector('title', text: user.name) 
						end
					end
				end
			end

		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in user }

			describe "visiting Users#edit page" do
				before { visit edit_user_path(wrong_user) }
				# Should redirect to the homepage because
				# users should never even try to edit another user's profile
				it { should have_selector('title', text: full_title('')) }
			end

			describe "submitting a PUT request to Users#update action" do
				before { put user_path(wrong_user) }
				# Redirects to the homepage because
				# users should never even try to edit another user's profile
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as non-admin user" do
			let(:non_admin) { FactoryGirl.create(:user) }
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in non_admin }

			describe "submitting a DELETE request to Users#destroy action" do
				before { delete user_path(user) }
				specify { response.should redirect_to(root_path) }
			end
		end

	end
	
end