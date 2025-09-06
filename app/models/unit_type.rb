class UnitType < ApplicationRecord
    has_many :units
    validates :code, :name, presence: true
    validates :code, uniqueness: true
    scope :active, -> { where(active: true) }
end
