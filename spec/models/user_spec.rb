require 'spec_helper'

describe User do
	
	before do
		@user = User.new(name: "Example User", email: "user@example.com",						
						password: "foobar", password_confirmation: "foobar")
	end
	
	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }

	it { should respond_to(:authenticate) }

	it { should be_valid }

	describe "when name is not present" do
		before { @user.name = " " }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "a" * 51 }
		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @user.email = " " }
		it { should_not be_valid }
	end

	describe "when email format is invalid" do
		invalid_adresses = %w[user@foo,com user_at_foo.org example.user@foo.]
		invalid_adresses.each do |invalid_adress|
			before { @user.email = invalid_adress }
			it { should_not be_valid }
		end
	end

	describe "when email format is valid" do
		valid_adresses = %w[user@foo.com THE_USER@foo.org first.last@foo.jp]
		valid_adresses.each do |valid_adress|
			before { @user.email = valid_adress }
			it { should be_valid }
		end
	end

	describe "when email adress is already taken" do
		before do
			user_with_same_email = @user.dup
			user_with_same_email.email = @user.email.upcase
			user_with_same_email.save
		end
		it { should_not be_valid }
	end

	describe "when password is not present" do
		before { @user.password = @user.password_confirmation = " " }
		it { should_not be_valid }
	end

	describe "when password doesn't match confirmation" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end

	describe "when password confirmation is nil" do
		before { @user.password_confirmation = nil }
		it { should_not be_valid }
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end

	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }

		describe "with valid password" do
			it { should == found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }

			it { should_not == user_for_invalid_password }
			specify { user_for_invalid_password.should be_false }
		end

	end

end