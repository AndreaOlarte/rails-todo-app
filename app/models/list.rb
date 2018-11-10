class List < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  validates :title, presence: true, length: { maximum: 50 }

  # CSV
  # def self.to_csv
  #   attributes = %w{id title user_id}

  #   CSV.generate(headers: true) do |csv|
  #     csv << attributes

  #     all.each do |todo|
  #       csv << todo.attributes.values_at(*attributes)
  #       # csv << attributes.values_at(*attributes)
  #     end
  #   end
  # end
end
