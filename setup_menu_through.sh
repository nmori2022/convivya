#!/usr/bin/env bash
set -euo pipefail

echo "=> Configurando menú con tablas intermedias (has_many :through)..."

# Asegúrate de ejecutar este script en la RAÍZ del proyecto Rails
if [ ! -f "config/application.rb" ]; then
  echo "ERROR: Este script debe ejecutarse desde la raíz de tu app Rails (donde está config/application.rb)."
  exit 1
fi

mkdir -p app/models db/migrate

# 1) Modelos
cat > app/models/menu_item.rb <<'RUBY'
class MenuItem < ApplicationRecord
  has_many :menu_item_permissions, dependent: :destroy
  has_many :permissions, through: :menu_item_permissions

  has_many :menu_item_roles, dependent: :destroy
  has_many :roles, through: :menu_item_roles

  validates :name, :path, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(:position, :id) }
end
RUBY

cat > app/models/menu_item_permission.rb <<'RUBY'
class MenuItemPermission < ApplicationRecord
  belongs_to :menu_item
  belongs_to :permission

  validates :menu_item_id, uniqueness: { scope: :permission_id }
end
RUBY

cat > app/models/menu_item_role.rb <<'RUBY'
class MenuItemRole < ApplicationRecord
  belongs_to :menu_item
  belongs_to :role

  validates :menu_item_id, uniqueness: { scope: :role_id }
end
RUBY

# 2) Actualiza/crea Permission y Role (se hace backup si existen)
ts_backup="$(date +%s)"

if [ -f app/models/permission.rb ]; then
  cp app/models/permission.rb "app/models/permission.rb.bak.${ts_backup}"
fi
cat > app/models/permission.rb <<'RUBY'
class Permission < ApplicationRecord
  has_and_belongs_to_many :roles

  has_many :menu_item_permissions, dependent: :destroy
  has_many :menu_items, through: :menu_item_permissions

  validates :action, :subject_class, presence: true
end
RUBY

if [ -f app/models/role.rb ]; then
  cp app/models/role.rb "app/models/role.rb.bak.${ts_backup}"
fi
cat > app/models/role.rb <<'RUBY'
class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :permissions

  has_many :menu_item_roles, dependent: :destroy
  has_many :menu_items, through: :menu_item_roles

  belongs_to :resource, polymorphic: true, optional: true
  validates :name, presence: true
  scopify
end
RUBY

# 3) Corrige el seeds.rb (si aplica) para data_source_exists?('menu_items')
if [ -f db/seeds.rb ]; then
  # Solo ajusta la verificación específica cuando falta el argumento
  if grep -q "defined?(MenuItem) && ActiveRecord::Base.connection.data_source_exists?" db/seeds.rb ; then
    sed -i.bak "s/defined?(MenuItem) && ActiveRecord::Base.connection.data_source_exists?/defined?(MenuItem) \&\& ActiveRecord::Base.connection.data_source_exists?('menu_items')/g" db/seeds.rb
    echo "   - Arreglado db/seeds.rb (se creó backup .bak)."
  fi
fi

# 4) Migraciones (Rails 8). Genera timestamps secuenciales.
ts1="$(date +%Y%m%d%H%M%S)"
mig1="db/migrate/${ts1}_create_menu_item_permissions.rb"
sleep 1
ts2="$(date +%Y%m%d%H%M%S)"
mig2="db/migrate/${ts2}_create_menu_item_roles.rb"

cat > "${mig1}" <<'RUBY'
class CreateMenuItemPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_permissions do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :menu_item_permissions, [:menu_item_id, :permission_id],
              unique: true, name: "idx_mip_on_item_and_permission"
  end
end
RUBY

cat > "${mig2}" <<'RUBY'
class CreateMenuItemRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_roles do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :menu_item_roles, [:menu_item_id, :role_id],
              unique: true, name: "idx_mir_on_item_and_role"
  end
end
RUBY

echo "=> Listo. Ahora ejecuta:"
echo "   bin/rails db:migrate"
echo "   bin/rails db:seed"