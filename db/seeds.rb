# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ==============================================================
# SEED OFICIAL DE CONVIVYA — elimina y carga datos completos
# ==============================================================

puts "Limpieza de tablas…"
ActiveRecord::Base.connection.disable_referential_integrity do
  # Joins opcionales si existen (evitamos errores si no están)
  %w[
    users_roles
    roles_permissions permissions_roles
    menu_items_roles roles_menu_items
    menu_items_permissions permissions_menu_items
  ].each do |jt|
    ActiveRecord::Base.connection.execute("DELETE FROM #{jt}") if ActiveRecord::Base.connection.data_source_exists?(jt)
  end

  # Tablas de negocio/seguridad/menú (borrado rápido)
  %w[
    units towers condominiums unit_types
    communes cities regions
    menu_items permissions roles users
  ].each do |t|
    ActiveRecord::Base.connection.execute("DELETE FROM #{t}") if ActiveRecord::Base.connection.data_source_exists?(t)
  end
end

# Reset de secuencias (PostgreSQL)
if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
  %w[regions cities communes condominiums towers unit_types units roles permissions users menu_items].each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t) rescue nil
  end
end

# ------------------------------
# ROLES
# ------------------------------
admin_role    = Role.find_or_create_by!(name: 'admin')
manager_role  = Role.find_or_create_by!(name: 'manager')
resident_role = Role.find_or_create_by!(name: 'resident')

# ------------------------------
# PERMISOS
# ------------------------------
if defined?(Permission) && ActiveRecord::Base.connection.data_source_exists?('permissions')
  # Base (los que enviaste)
  base_perms = [
    { name: 'Ver Dashboard',       action: 'read',   subject_class: 'Dashboard',   description: 'Acceso al panel' },
    { name: 'Gestionar Edificios', action: 'manage', subject_class: 'Building',    description: 'CRUD de edificios' },
    { name: 'Gestionar Unidades',  action: 'manage', subject_class: 'Unit',        description: 'CRUD de unidades' },
    { name: 'Ver Pagos',           action: 'read',   subject_class: 'Payment',     description: 'Ver pagos' },
    { name: 'Gestionar Gastos',    action: 'manage', subject_class: 'Expense',     description: 'Gastos comunes' }
  ]

  # Complementos (para menú dinámico completo)
  extra_perms = [
    { name: 'Gestionar Residentes',  action: 'manage', subject_class: 'Resident',     description: 'CRUD de residentes' },
    { name: 'Gestionar Mantenciones',action: 'manage', subject_class: 'Maintenance',   description: 'Órdenes y mantenciones' },
    { name: 'Ver Reportes',          action: 'read',   subject_class: 'Report',       description: 'Acceso a reportes' },
    { name: 'Ver Notificaciones',    action: 'read',   subject_class: 'Notification', description: 'Centro de notificaciones' }
  ]

  (base_perms + extra_perms).each do |h|
    Permission.find_or_create_by!(action: h[:action], subject_class: h[:subject_class]).tap { |p| p.update!(h) }
  end

  # Asignación de permisos a roles (si el modelo Role soporta :permissions)
  if admin_role.respond_to?(:permissions)
    admin_role.permissions   = Permission.all
    manager_role.permissions = Permission.where(subject_class: %w[Dashboard Building Unit Payment Expense Resident Maintenance Report Notification])
    resident_role.permissions = Permission.where(action: 'read')
  else
    puts '· Aviso: El modelo Role no tiene asociación :permissions; se omite asignación directa.'
  end
else
  puts '· Aviso: No existe el modelo/tabla Permission; se omite el seeding de permisos.'
end

# ------------------------------
# USUARIO ADMIN
# ------------------------------
admin_user = User.find_or_create_by!(email: 'admin@demo.cl') do |u|
  u.name = 'Admin'
  u.password = 'Admin123!'
  u.password_confirmation = 'Admin123!'
end
admin_user.add_role(:admin)

# ------------------------------
# MENÚ DINÁMICO
# ------------------------------
if defined?(MenuItem) && ActiveRecord::Base.connection.data_source_exists?('menu_items')
  menu_def = [
    ['Dashboard',      '/',                      'fas fa-tachometer-alt', ''],
    ['Edificios',      '/buildings',             'fas fa-building',        ''],
    ['Unidades',       '/units',                 'fas fa-home',            ''],
    ['Residentes',     '/residents',             'fas fa-users',           ''],
    ['Mantenimiento',  '/maintenance',           'fas fa-tools',           ''],
    ['Pagos',          '/payments',              'fas fa-credit-card',     ''],
    ['Gastos Comunes', '/expenses',              'fas fa-receipt',         ''],
    ['Reportes',       '/reports',               'fas fa-chart-bar',       ''],
    ['Notificaciones', '/notifications',         'fas fa-bell',            '']
  ]

  # Mapeo menú → subject_class de permiso (por nombre)
  perm_map = {
    'Dashboard'      => 'Dashboard',
    'Edificios'      => 'Building',
    'Unidades'       => 'Unit',
    'Residentes'     => 'Resident',
    'Mantenimiento'  => 'Maintenance',
    'Pagos'          => 'Payment',
    'Gastos Comunes' => 'Expense',
    'Reportes'       => 'Report',
    'Notificaciones' => 'Notification'
  }

  menu_def.each_with_index do |(name, path, icon, style), i|
    item = MenuItem.find_or_create_by!(name: name, path: path)
    item.update!(icon_class: icon, style_class: style, position: i + 1)

    # Si hay permisos y asociación en MenuItem, vincula el ítem al permiso correspondiente
    if defined?(Permission) && item.respond_to?(:permissions)
      subj = perm_map[name]
      # Intenta 'read' primero, luego 'manage'
      perm = Permission.find_by(subject_class: subj, action: 'read') || Permission.find_by(subject_class: subj, action: 'manage')
      item.permissions << perm if perm && !item.permissions.exists?(perm.id)
    end

    # Si no hay permisos pero sí asociación con roles, asocia roles por defecto
    if item.respond_to?(:roles)
      roles_for_item = case perm_map[name]
                       when 'Dashboard', 'Notification'
                         [admin_role, manager_role, resident_role]
                       else
                         [admin_role, manager_role]
                       end
      roles_for_item.each { |r| item.roles << r if r && !item.roles.exists?(r.id) }
    end
  end
else
  puts '· Aviso: No existe el modelo/tabla MenuItem; se omite el seeding del menú.'
end

# ------------------------------
# UBICACIÓN CHILE
# ------------------------------
rm = Region.find_or_create_by!(code: 'RM') { |r| r.name = 'Región Metropolitana de Santiago' }

scl_city = City.find_or_create_by!(region: rm, code: 'STGO') { |c| c.name = 'Santiago' }

com_santiago = Commune.find_or_create_by!(region: rm, code: 'SANTIAGO') { |c| c.name = 'Santiago' }
com_maipu    = Commune.find_or_create_by!(region: rm, code: 'MAIPU')    { |c| c.name = 'Maipú' }
com_nunoa    = Commune.find_or_create_by!(region: rm, code: 'NUNOA')    { |c| c.name = 'Ñuñoa' }

# ------------------------------
# TIPOS DE UNIDAD
# ------------------------------
{
  'DEP' => 'Departamento',
  'CAS' => 'Casa',
  'BOD' => 'Bodega',
  'EST' => 'Estacionamiento',
  'LOC' => 'Local',
  'OFI' => 'Oficina'
}.each do |code, name|
  UnitType.find_or_create_by!(code: code) { |t| t.name = name }
end

def ut(code) = UnitType.find_by!(code: code)

# ------------------------------
# CONDOMINIOS
# ------------------------------
condo1 = Condominium.find_or_create_by!(code: 'CVY-001') do |c|
  c.name          = 'Convivya Jardines del Sur'
  c.address_line  = 'Av. Siempre Viva 123'
  c.postal_code   = '8320000'
  c.condo_kind    = :edificio
  c.status        = :activo
  c.phone         = '+56 2 2345 6789'
  c.email         = 'admin@jardin-sur.cl'
  c.description   = 'Torre en altura con amenities.'
  c.declared_units = 120
  c.region  = rm
  c.city    = scl_city
  c.commune = com_santiago
  c.administrator = admin_user
end

condo2 = Condominium.find_or_create_by!(code: 'CVY-002') do |c|
  c.name          = 'Convivya Altos de Maipú'
  c.address_line  = 'Camino Real 456'
  c.postal_code   = '9250000'
  c.condo_kind    = :conjunto_casas
  c.status        = :activo
  c.phone         = '+56 2 9988 7766'
  c.email         = 'contacto@altos-maipu.cl'
  c.description   = 'Conjunto de casas con áreas verdes.'
  c.declared_units = 80
  c.region  = rm
  c.city    = scl_city
  c.commune = com_maipu
  c.administrator = admin_user
end

# ------------------------------
# TORRES (para condominio en altura)
# ------------------------------
tower_a = Tower.find_or_create_by!(condominium: condo1, code: 'A') do |t|
  t.name = 'Torre A'
  t.floors = 20
  t.address_line = 'Av. Siempre Viva 123 - Torre A'
  t.postal_code  = '8320000'
  t.region  = rm
  t.city    = scl_city
  t.commune = com_santiago
end

tower_b = Tower.find_or_create_by!(condominium: condo1, code: 'B') do |t|
  t.name = 'Torre B'
  t.floors = 18
  t.address_line = 'Av. Siempre Viva 123 - Torre B'
  t.postal_code  = '8320000'
  t.region  = rm
  t.city    = scl_city
  t.commune = com_santiago
end

# ------------------------------
# UNIDADES
# ------------------------------
# Condo1 (edificio): dirección propia detallando depto pero misma ubicación que la torre
[
  { code: 'A-101',   number: '101',   tower: tower_a, surface_m2: 55.0, bedrooms: 2, bathrooms: 1.0, status: :disponible, rent_cents: 420000, unit_type: ut('DEP'), floor: 1,  orientation: :norte, feature_balcony: true,  address_line: 'Av. Siempre Viva 123, Depto 101', postal_code: '8320000', region: rm, city: scl_city, commune: com_santiago },
  { code: 'A-1501',  number: '1501',  tower: tower_a, surface_m2: 72.5, bedrooms: 3, bathrooms: 2.0, status: :ocupada,    rent_cents: 650000, unit_type: ut('DEP'), floor: 15, orientation: :este,  feature_terrace: true, address_line: 'Av. Siempre Viva 123, Depto 1501', postal_code: '8320000', region: rm, city: scl_city, commune: com_santiago },
  { code: 'B-803',   number: '803',   tower: tower_b, surface_m2: 60.0, bedrooms: 2, bathrooms: 1.0, status: :disponible, rent_cents: 480000, unit_type: ut('DEP'), floor: 8,  orientation: :oeste, address_line: 'Av. Siempre Viva 123, Depto 803', postal_code: '8320000', region: rm, city: scl_city, commune: com_santiago },
  { code: 'EST-B1',  number: 'P1-23', tower: tower_b, surface_m2: 12.0, status: :disponible, rent_cents: 60000, unit_type: ut('EST'), floor: 1,  orientation: :sur, feature_parking: true, description: 'Estacionamiento techado', address_line: 'Av. Siempre Viva 123, Piso -1, Est. 23', postal_code: '8320000', region: rm, city: scl_city, commune: com_santiago },
  { code: 'BOD-02',  number: 'B2-02', tower: tower_b, surface_m2: 4.0,  status: :disponible, rent_cents: 30000, unit_type: ut('BOD'), floor: 2,  orientation: :sur, feature_storage: true, address_line: 'Av. Siempre Viva 123, Bodega B2-02', postal_code: '8320000', region: rm, city: scl_city, commune: com_santiago }
].each do |attrs|
  Unit.find_or_create_by!(condominium: condo1, code: attrs[:code]) { |u| u.attributes = attrs.except(:code) }
end

# Condo2 (conjunto de casas): unidades con dirección propia distinta
[
  { code: 'C-01',   number: 'Casa 01', surface_m2: 90.0,  bedrooms: 3, bathrooms: 2.0, status: :disponible, rent_cents: 750000, unit_type: ut('CAS'), floor: 0, orientation: :norte, feature_garden: true,    address_line: 'Pasaje Los Robles 12',     postal_code: '9250011', region: rm, city: scl_city, commune: com_maipu },
  { code: 'C-02',   number: 'Casa 02', surface_m2: 120.0, bedrooms: 4, bathrooms: 3.0, status: :ocupada,    rent_cents: 950000, unit_type: ut('CAS'), floor: 0, orientation: :este,  feature_fireplace: true, address_line: 'Calle Las Flores 345',   postal_code: '9250022', region: rm, city: scl_city, commune: com_maipu },
  { code: 'EST-01', number: 'Est-01',  surface_m2: 13.0,  status: :disponible, rent_cents: 70000, unit_type: ut('EST'), floor: 0, orientation: :oeste, feature_parking: true,   address_line: 'Pasaje Los Robles S/N, Est. 1', postal_code: '9250011', region: rm, city: scl_city, commune: com_maipu }
].each do |attrs|
  Unit.find_or_create_by!(condominium: condo2, code: attrs[:code]) { |u| u.attributes = attrs.except(:code) }
end

# Recontar (por si ya existían)
Condominium.find_each { |c| Condominium.reset_counters(c.id, :towers, :units) }
Tower.find_each       { |t| Tower.reset_counters(t.id, :units) }

puts 'SEED COMPLETO OK ✅'