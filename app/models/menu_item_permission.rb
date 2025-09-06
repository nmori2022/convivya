class MenuItemPermission < ApplicationRecord
  belongs_to :menu_item
  belongs_to :permission

  validates :menu_item_id, uniqueness: { scope: :permission_id }
end
