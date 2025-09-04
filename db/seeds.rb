# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Roles
admin    = Role.find_or_create_by!(name: 'admin')
manager  = Role.find_or_create_by!(name: 'manager')
resident = Role.find_or_create_by!(name: 'resident')

# Permisos (ejemplos)
perms = [
  { name: 'Ver Dashboard', action: 'read',  subject_class: 'Dashboard', description: 'Acceso al panel' },
  { name: 'Gestionar Edificios', action: 'manage', subject_class: 'Building', description: 'CRUD de edificios' },
  { name: 'Gestionar Unidades',  action: 'manage', subject_class: 'Unit',     description: 'CRUD de unidades' },
  { name: 'Ver Pagos',           action: 'read',   subject_class: 'Payment',  description: 'Ver pagos' },
  { name: 'Gestionar Gastos',    action: 'manage', subject_class: 'Expense',  description: 'Gastos comunes' }
]

perms.map! do |h|
  Permission.find_or_create_by!(h.slice(:action, :subject_class)).tap do |p|
    p.update!(h)
  end
end

# Asignación de permisos a roles
admin.permissions   = Permission.all
manager.permissions = Permission.where(subject_class: %w[Dashboard Building Unit Payment Expense])
resident.permissions = Permission.where(action: 'read')

# Usuario admin demo
admin_user = User.find_or_create_by!(email: 'admin@demo.cl') do |u|
  u.name = 'Admin'
  u.password = 'Admin123!'
end
admin_user.add_role(:admin)

# Menú configurable (icon_class = Font Awesome, style_class = Bootstrap)
menu = [
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
menu.each_with_index do |(name, path, icon, style), i|
  MenuItem.find_or_create_by!(name:, path:) do |m|
    m.icon_class = icon
    m.style_class = style
    m.position = i+1
  end
end

puts "SEED OK ✅"
