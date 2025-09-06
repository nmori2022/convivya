class Region < ApplicationRecord
    has_many :cities, dependent: :destroy
    has_many :communes, dependent: :destroy
    validates :code, :name, presence: true
    validates :code, uniqueness: true
end
