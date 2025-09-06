class CreateTowers < ActiveRecord::Migration[8.0]
  def change
    create_table :towers do |t|
      t.references :condominium, null: false, foreign_key: true
      t.string :code, null: false # Código de torre dentro del condominio (p.ej. 'A')
      t.string :name, null: false # Nombre descriptivo (p.ej. 'Torre A')
      t.integer :floors, default: 0 # Nº de pisos de la torre


      t.string :address_line, null: false
      t.string :postal_code
      t.references :region, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true


      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6


      t.text :description
      t.integer :units_count, null: false, default: 0
      t.timestamps
    end


    add_index :towers, [:condominium_id, :code], unique: true
  end
end
