class Task < ApplicationRecord
  belongs_to :list

  # CSV
  def self.to_csv
    attributes = %w{done description}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |task|
        csv << task.attributes.values_at(*attributes)
        # csv << attributes.values_at(*attributes)
      end
    end
  end
end
