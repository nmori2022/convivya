class City < ApplicationRecord
  belongs_to :region
  has_many :condominiums
  has_many :towers
  has_many :units
  validates :code, :name, presence: true
  validates :code, uniqueness: { scope: :region_id }
end
