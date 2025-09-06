class CreateCondominiums < ActiveRecord::Migration[8.0]
  def change
    create_table :condominiums do |t|
      t.string :code, null: false # Código interno único
      t.string :name, null: false # Nombre del condominio
      t.string :address_line, null: false # Dirección (calle y número)
      t.string :postal_code # Código postal


      t.integer :condo_kind, null: false, default: 0 # {conjunto_casas, edificio, mixto}
      t.integer :status, null: false, default: 0 # {activo, mantenimiento, inactivo}


      t.string :phone
      t.string :email
      t.text :description
      t.integer :declared_units, null: false, default: 0


      t.references :administrator, null: false, foreign_key: { to_table: :users }
      t.references :region, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true


      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6


      t.integer :towers_count, null: false, default: 0
      t.integer :units_count, null: false, default: 0
      t.timestamps
    end


    add_index :condominiums, :code, unique: true
  end
end
