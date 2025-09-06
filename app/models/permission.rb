class Permission < ApplicationRecord
  has_and_belongs_to_many :roles

  has_many :menu_item_permissions, dependent: :destroy
  has_many :menu_items, through: :menu_item_permissions

  validates :action, :subject_class, presence: true
end
