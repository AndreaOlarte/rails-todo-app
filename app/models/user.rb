class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :lists, dependent: :destroy
  has_one_attached :avatar
  validates :name, length: { maximum: 50 }
  validates :email, length: { maximum: 50 }
  validates :description, length: { maximum: 150 }
end
