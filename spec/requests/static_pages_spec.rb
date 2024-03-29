require 'spec_helper'

describe "Static pages" do

	let(:base_title) { "Ruby on Rails Tutorial Sample App" }

	subject { page }

	shared_examples_for "all static pages" do
		it { should have_selector 'h1', text: heading }
		it { should have_selector 'title', text: full_title(page_title) }
	end

	describe "Home page" do
		before { visit root_path }

		let(:heading) 		{ 'Sample App' }
		let(:page_title) 	{ '' }

		it_should_behave_like "all static pages"
		it { should_not have_selector('title', text: "| Home") }

		describe "for signed-in user" do
			let (:user) { FactoryGirl.create(:user) }
			let (:non_owned_micropost) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user), content: "Non owned") }
			before do
				FactoryGirl.create(:micropost, user: user, content: "Lorem psum")
				FactoryGirl.create(:micropost, user: user, content: "Dolore sit amet")
				sign_in user
				visit root_path
			end

			it "should render the user's feed" do
				user.feed.each do |item|
					page.should have_selector("li##{item.id}", content: item.content)
				end
			end

			describe "should not show delete links for non-owned microposts" do
				it {should_not have_link("delete", href: microposts_path(non_owned_micropost))}
			end
		end
	end

	describe "Help page" do
		before { visit help_path }

		let(:heading) 		{ 'Help' }
		let(:page_title) 	{ 'Help' }

		it_should_behave_like "all static pages"
	end

	describe "About page" do
		before { visit about_path }

		let(:heading) 		{ 'About Us' }
		let(:page_title) 	{ 'About Us' }

		it_should_behave_like "all static pages"
	end

	describe "Contact page" do
		before { visit contact_path }

		let(:heading) 		{ 'Contact' }
		let(:page_title) 	{ 'Contact' }

		it_should_behave_like "all static pages"
	end

	it "should have the right links on the layout" do
		visit root_path
		click_link "About"
		page.should have_selector 'title', text: full_title('About Us')
		click_link "Help"
		page.should have_selector 'title', text: full_title('Help')
		click_link "Contact"
		page.should have_selector 'title', text: full_title('Contact')
		click_link "Home"
		page.should have_selector 'title', text: full_title('')
		click_link "Sign up now!"
		page.should have_selector 'title', text: full_title('Sign up')
	end

end