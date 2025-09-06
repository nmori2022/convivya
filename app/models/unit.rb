# app/models/unit.rb
class Unit < ApplicationRecord
  belongs_to :condominium, counter_cache: true
  belongs_to :tower, optional: true, counter_cache: true
  belongs_to :unit_type

  # Ubicación propia de la unidad
  belongs_to :region
  belongs_to :city
  belongs_to :commune

  # 👇 usa la forma posicional (símbolo primero)
  enum :status,      { disponible: 0, ocupada: 1, mantenimiento: 2 }
  enum :orientation, { norte: 0, sur: 1, este: 2, oeste: 3, noreste: 4, noroeste: 5, sureste: 6, suroeste: 7 }

  validates :code, :number, :surface_m2, :address_line, presence: true
  validates :code, uniqueness: { scope: :condominium_id }

  # Dirección amigable
  def full_address
    [address_line, commune&.name, city&.name, region&.name, postal_code].compact.join(', ')
  end

  # Regla de coherencia: si hay torre, la ubicación debe coincidir con la torre; si no hay torre, con el condominio
  validate :location_integrity
  private
  def location_integrity
    if tower
      errors.add(:region, 'debe coincidir con la de la torre') if region_id != tower.region_id
      errors.add(:city, 'debe coincidir con la de la torre') if city_id != tower.city_id
      errors.add(:commune, 'debe coincidir con la de la torre') if commune_id != tower.commune_id
    else
      errors.add(:region, 'debe coincidir con la del condominio') if region_id != condominium.region_id
      errors.add(:city, 'debe coincidir con la del condominio') if city_id != condominium.city_id
      errors.add(:commune, 'debe coincidir con la del condominio') if commune_id != condominium.commune_id
    end
  end
end
