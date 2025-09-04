class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name
      t.string :action
      t.string :subject_class
      t.string :description
      t.string :icon_class
      t.string :style_class

      t.timestamps
    end
  end
end
