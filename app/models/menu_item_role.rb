class MenuItemRole < ApplicationRecord
  belongs_to :menu_item
  belongs_to :role

  validates :menu_item_id, uniqueness: { scope: :role_id }
end
