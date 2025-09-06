class CreateMenuItemRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_roles do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :menu_item_roles, [:menu_item_id, :role_id],
              unique: true, name: "idx_mir_on_item_and_role"
  end
end
