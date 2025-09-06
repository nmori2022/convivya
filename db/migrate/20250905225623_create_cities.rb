class CreateCities < ActiveRecord::Migration[8.0]
  def change
  create_table :cities do |t|
    t.references :region, null: false, foreign_key: true
    t.string :code, null: false # Código corto de ciudad
    t.string :name, null: false # Nombre de ciudad
    t.timestamps
  end
  add_index :cities, [:region_id, :code], unique: true
  end
end
