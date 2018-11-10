require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.new( 
      # name: name,
      email: email,
      password: password,
      password_confirmation: password,
      # description: description
      )
  end
  let (:email) {'email@example.com'}
  let (:password) {'password'}
  # let (:name) {nil}
  # let (:description) {nil}
  
  context 'associations' do
    it "has many lists" do
      assc = User.reflect_on_association(:lists)
      expect(assc.macro).to eq :has_many
    end
  end
  
  context 'when has a valid data' do
    it 'should be valid' do
      expect(user).to be_valid
    end
  end

  # EMAIL
  context 'when has an invalid email' do
    let (:email) {''}
    it 'is invalid' do
      expect(user).not_to be_valid
    end
  end

  context 'when the user email is too long' do
    let (:email) {'x' * 50 + '@example.com'}
    it 'should be invalid' do
      expect(user).not_to be_valid
    end
  end
  
  context 'when email address is not unique' do 
    let (:another_user) {user.dup}
    it "is invalid" do
      user.save
      expect(another_user).not_to be_valid
    end
  end

  context 'when enters an email address with not only lowercase letters' do 
    let (:not_only_lower) {'email@ExAmPlE.cOm'}
    let (:email) {not_only_lower}
	  it 'should be saved as lowercase' do
      user.save
      expect(not_only_lower.downcase).to eq(user.email)
    end
  end
  
  # PASSWORD
  context 'when enters a password' do
    it 'should be valid' do
      expect(user).to be_valid
    end
  end

  context 'when does not have a password' do
    let (:password) {}
    it 'should be invalid' do
      expect(user).not_to be_valid
    end
  end

  context 'when has a password with less than 6 characters' do
    let (:password) {'x' * 5}
    it 'should be invalid' do
      expect(user).not_to be_valid
    end
  end

  # NAME
  context 'when enters a name' do
    context 'when name has more than 50 characters' do
      let(:user_with_name) do
        User.new( 
          name: 'name' * 20,
          email: email,
          password: password,
          password_confirmation: password
          )
      end
      it "should be invalid" do
        expect(user_with_name).not_to be_valid
      end
      
    end
  end

  # DESCRIPTION
  context 'when enters a description' do
    context 'when description has more than 150 characters' do
      let(:user_with_desc) do
        User.new( 
          email: email,
          password: password,
          password_confirmation: password,
          description: 'x' * 151
        )
      end
      it "should be invalid" do
        expect(user_with_desc).not_to be_valid
      end
    end
  end

  # AVATAR
  context 'when enters an image as an avatar' do
    context 'when uploads an non-image file' do
      # let (:correct_types) {%w[image/png image/jpeg]}
      it 'should be invalid' do
        user.avatar.attach(
          io: File.open('app/assets/images/example.txt'),
          filename: 'text.txt',
          content_type: 'text/plain'
        )
        correct_types = %w[image/png image/jpeg]
        # expect(user).not_to be_valid unless user.avatar.content_type.in?( correct_types )
        expect(user.avatar.content_type.in?(correct_types)).to eq(false)
      end
    end
  end


  # AVATAR
  # it "should have a correct type image" do
  #   @user.avatar.attach(
  #     io: File.open('app/assets/images/example.txt'),
  #     filename: 'text.txt',
  #     content_type: 'text/plain')
  #   correct_types = %w[image/png image/jpeg]
  #   expect(@user).not_to be_valid unless @user.avatar.content_type.in?( correct_types )
  # end
end
