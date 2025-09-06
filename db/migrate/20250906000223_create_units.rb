class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.references :condominium, null: false, foreign_key: true
      t.references :tower, null: true, foreign_key: true
      t.references :unit_type, null: false, foreign_key: true


      t.string :code, null: false # Código único dentro del condominio
      t.string :number, null: false # Identificador visible (p.ej. '1501', 'Casa 02')


      t.decimal :surface_m2, precision: 8, scale: 2, null: false
      t.integer :bedrooms
      t.decimal :bathrooms, precision: 3, scale: 1


      t.integer :status, null: false, default: 0 # {disponible, ocupada, mantenimiento}
      t.integer :rent_cents, null: false, default: 0 # CLP


      t.string :owner_name
      t.string :phone
      t.string :email


      t.integer :floor
      t.integer :orientation, null: false, default: 0 # {norte, sur, este, oeste, noreste, noroeste, sureste, suroeste}


      # Atributos/amenities comunes
      t.boolean :feature_balcony, default: false
      t.boolean :feature_terrace, default: false
      t.boolean :feature_garden, default: false
      t.boolean :feature_fireplace, default: false
      t.boolean :feature_parking, default: false
      t.boolean :feature_storage, default: false
      t.boolean :feature_ac, default: false
      t.boolean :feature_furnished, default: false


      # **NUEVO**: Dirección propia de la unidad
      t.string :address_line, null: false
      t.string :postal_code
      t.references :region, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true


      t.text :description
      t.timestamps
    end


    add_index :units, [:condominium_id, :code], unique: true
    add_index :units, [:condominium_id, :number]
  end
end
