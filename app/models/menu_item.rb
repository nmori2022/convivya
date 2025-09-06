class MenuItem < ApplicationRecord
  has_many :menu_item_permissions, dependent: :destroy
  has_many :permissions, through: :menu_item_permissions

  has_many :menu_item_roles, dependent: :destroy
  has_many :roles, through: :menu_item_roles

  validates :name, :path, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(:position, :id) }
end
