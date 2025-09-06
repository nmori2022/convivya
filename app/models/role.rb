class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :permissions

  has_many :menu_item_roles, dependent: :destroy
  has_many :menu_items, through: :menu_item_roles

  belongs_to :resource, polymorphic: true, optional: true
  validates :name, presence: true
  scopify
end
