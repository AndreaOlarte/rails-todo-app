require 'rails_helper'

RSpec.describe List, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  let(:user) do
    User.new(id: 10, email: 'email@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:list) do
    user.lists.new(title: title, user_id: user.id)
  end
  let (:title) {'This is a title'}

  context 'associations' do
    it "belongs to user" do
      assc = List.reflect_on_association(:user)
      expect(assc.macro).to eq :belongs_to
    end
    it "has many tasks" do
      assc = List.reflect_on_association(:tasks)
      expect(assc.macro).to eq :has_many
    end
  end

  context 'when has valid data' do
    it 'should be valid' do
      expect(list).to be_valid
    end
  end

  # context 'when user does not exist' do
  #   it 'should be invalid' do
  #     list.user_id = 3000
  #     expect(list).not_to be_valid
  #   end
  # end

  context 'when has an invalid title' do
    let (:title) {''}
    it 'should be invalid' do
      # list.title = nil
      expect(list).not_to be_valid
    end
  end

  context 'when has a title longer than 50 characters' do
    let (:title) {'x' * 51}
    it 'should be invalid' do
      # list.title = nil
      expect(list).not_to be_valid
    end
  end
end
