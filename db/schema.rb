# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_06_052658) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cities", force: :cascade do |t|
    t.bigint "region_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id", "code"], name: "index_cities_on_region_id_and_code", unique: true
    t.index ["region_id"], name: "index_cities_on_region_id"
  end

  create_table "communes", force: :cascade do |t|
    t.bigint "region_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id", "code"], name: "index_communes_on_region_id_and_code", unique: true
    t.index ["region_id"], name: "index_communes_on_region_id"
  end

  create_table "condominiums", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "address_line", null: false
    t.string "postal_code"
    t.integer "condo_kind", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "phone"
    t.string "email"
    t.text "description"
    t.integer "declared_units", default: 0, null: false
    t.bigint "administrator_id", null: false
    t.bigint "region_id", null: false
    t.bigint "city_id", null: false
    t.bigint "commune_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "towers_count", default: 0, null: false
    t.integer "units_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_condominiums_on_administrator_id"
    t.index ["city_id"], name: "index_condominiums_on_city_id"
    t.index ["code"], name: "index_condominiums_on_code", unique: true
    t.index ["commune_id"], name: "index_condominiums_on_commune_id"
    t.index ["region_id"], name: "index_condominiums_on_region_id"
  end

  create_table "menu_item_permissions", force: :cascade do |t|
    t.bigint "menu_item_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id", "permission_id"], name: "idx_mip_on_item_and_permission", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_permissions_on_menu_item_id"
    t.index ["permission_id"], name: "index_menu_item_permissions_on_permission_id"
  end

  create_table "menu_item_roles", force: :cascade do |t|
    t.bigint "menu_item_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id", "role_id"], name: "idx_mir_on_item_and_role", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_roles_on_menu_item_id"
    t.index ["role_id"], name: "index_menu_item_roles_on_role_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.string "icon_class"
    t.string "style_class"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.string "action"
    t.string "subject_class"
    t.string "description"
    t.string "icon_class"
    t.string "style_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_regions_on_code", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "towers", force: :cascade do |t|
    t.bigint "condominium_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.integer "floors", default: 0
    t.string "address_line", null: false
    t.string "postal_code"
    t.bigint "region_id", null: false
    t.bigint "city_id", null: false
    t.bigint "commune_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.text "description"
    t.integer "units_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_towers_on_city_id"
    t.index ["commune_id"], name: "index_towers_on_commune_id"
    t.index ["condominium_id", "code"], name: "index_towers_on_condominium_id_and_code", unique: true
    t.index ["condominium_id"], name: "index_towers_on_condominium_id"
    t.index ["region_id"], name: "index_towers_on_region_id"
  end

  create_table "unit_types", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_unit_types_on_code", unique: true
  end

  create_table "units", force: :cascade do |t|
    t.bigint "condominium_id", null: false
    t.bigint "tower_id"
    t.bigint "unit_type_id", null: false
    t.string "code", null: false
    t.string "number", null: false
    t.decimal "surface_m2", precision: 8, scale: 2, null: false
    t.integer "bedrooms"
    t.decimal "bathrooms", precision: 3, scale: 1
    t.integer "status", default: 0, null: false
    t.integer "rent_cents", default: 0, null: false
    t.string "owner_name"
    t.string "phone"
    t.string "email"
    t.integer "floor"
    t.integer "orientation", default: 0, null: false
    t.boolean "feature_balcony", default: false
    t.boolean "feature_terrace", default: false
    t.boolean "feature_garden", default: false
    t.boolean "feature_fireplace", default: false
    t.boolean "feature_parking", default: false
    t.boolean "feature_storage", default: false
    t.boolean "feature_ac", default: false
    t.boolean "feature_furnished", default: false
    t.string "address_line", null: false
    t.string "postal_code"
    t.bigint "region_id", null: false
    t.bigint "city_id", null: false
    t.bigint "commune_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_units_on_city_id"
    t.index ["commune_id"], name: "index_units_on_commune_id"
    t.index ["condominium_id", "code"], name: "index_units_on_condominium_id_and_code", unique: true
    t.index ["condominium_id", "number"], name: "index_units_on_condominium_id_and_number"
    t.index ["condominium_id"], name: "index_units_on_condominium_id"
    t.index ["region_id"], name: "index_units_on_region_id"
    t.index ["tower_id"], name: "index_units_on_tower_id"
    t.index ["unit_type_id"], name: "index_units_on_unit_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "cities", "regions"
  add_foreign_key "communes", "regions"
  add_foreign_key "condominiums", "cities"
  add_foreign_key "condominiums", "communes"
  add_foreign_key "condominiums", "regions"
  add_foreign_key "condominiums", "users", column: "administrator_id"
  add_foreign_key "menu_item_permissions", "menu_items"
  add_foreign_key "menu_item_permissions", "permissions"
  add_foreign_key "menu_item_roles", "menu_items"
  add_foreign_key "menu_item_roles", "roles"
  add_foreign_key "towers", "cities"
  add_foreign_key "towers", "communes"
  add_foreign_key "towers", "condominiums"
  add_foreign_key "towers", "regions"
  add_foreign_key "units", "cities"
  add_foreign_key "units", "communes"
  add_foreign_key "units", "condominiums"
  add_foreign_key "units", "regions"
  add_foreign_key "units", "towers"
  add_foreign_key "units", "unit_types"
end
