require 'rails_helper'

RSpec.describe Task, type: :model do
  context 'associations' do
    it "belongs to a list" do
      assc = Task.reflect_on_association(:list)
      expect(assc.macro).to eq :belongs_to
    end
  end
end
