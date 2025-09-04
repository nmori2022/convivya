class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :path
      t.string :icon_class
      t.string :style_class
      t.integer :position

      t.timestamps
    end
  end
end
