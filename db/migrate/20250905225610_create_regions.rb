class CreateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :regions do |t|
      t.string :code, null: false # Código corto: p.ej. 'RM'
      t.string :name, null: false # Nombre: 'Región Metropolitana de Santiago'
      t.timestamps
    end
    add_index :regions, :code, unique: true
  end
end
