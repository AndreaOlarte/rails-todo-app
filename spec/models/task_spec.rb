require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) do
    User.new(id: 10, email: 'email@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:list) do
    user.lists.new(id: 5, title: 'This is a title', user_id: user.id)
  end
  let(:task) do
    list.tasks.new(description: description, list_id: list.id)
  end
  let (:description) {'This is a brief description'}

  context 'associations' do
    it "belongs to a list" do
      assc = Task.reflect_on_association(:list)
      expect(assc.macro).to eq :belongs_to
    end
  end

  context 'when has valid data' do
    it 'should be valid' do
      expect(task).to be_valid
    end
  end

  # context 'when user does not exist' do
  #   it 'should be invalid' do
  #     list.user_id = 3000
  #     expect(list).not_to be_valid
  #   end
  # end

  context 'when has an invalid description' do
    context 'when description has no characters' do
      let (:description) {''}
      it 'should be invalid' do
        expect(task).not_to be_valid
      end
    end
    context 'when has a description longer than 50 characters' do
      let (:description) {'x' * 76}
      it 'should be invalid' do
        expect(task).not_to be_valid
      end
    end
  end
end
