class CreateUnitTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_types do |t|
      t.string :code, null: false # DEP, CAS, BOD, EST, etc.
      t.string :name, null: false # Departamento, Casa, Bodega...
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :unit_types, :code, unique: true
  end
end
