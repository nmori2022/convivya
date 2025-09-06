class CreateMenuItemPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_permissions do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :menu_item_permissions, [:menu_item_id, :permission_id],
              unique: true, name: "idx_mip_on_item_and_permission"
  end
end
