class CreateCommunes < ActiveRecord::Migration[8.0]
  def change
    create_table :communes do |t|
      t.references :region, null: false, foreign_key: true
      t.string :code, null: false # Código corto de comuna
      t.string :name, null: false # Nombre de comuna
      t.timestamps
    end
    add_index :communes, [:region_id, :code], unique: true
  end
end
