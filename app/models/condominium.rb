class Condominium < ApplicationRecord
  # Dueño/administrador del condominio
  belongs_to :administrator, class_name: 'User'


  # Ubicación normalizada
  belongs_to :region
  belongs_to :city
  belongs_to :commune


  # Relaciones con dominio
  has_many :towers, dependent: :destroy
  has_many :units, dependent: :destroy


  # Catálogos (usa la sintaxis posicional para evitar el ArgumentError)
  enum :condo_kind, { conjunto_casas: 0, edificio: 1, mixto: 2 }
  enum :status,     { activo: 0, mantenimiento: 1, inactivo: 2 }


  # Validaciones
  validates :code, :name, :address_line, presence: true
  validates :code, uniqueness: true


  # Dirección amigable para mostrar
  def full_address
    [address_line, commune&.name, city&.name, region&.name, postal_code].compact.join(', ')
  end


  # Consistencia básica entre región–ciudad–comuna (mismo id de región)
  validate :location_integrity
  private
  def location_integrity
    errors.add(:city, 'debe pertenecer a la misma región') if city && region && city.region_id != region_id
    errors.add(:commune, 'debe pertenecer a la misma región') if commune && region && commune.region_id != region_id
  end
end
