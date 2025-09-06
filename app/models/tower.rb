class Tower < ApplicationRecord
  belongs_to :condominium, counter_cache: true


  # Ubicación debe coincidir con el condominio
  belongs_to :region
  belongs_to :city
  belongs_to :commune


  has_many :units, dependent: :nullify


  validates :code, :name, :address_line, presence: true
  validates :code, uniqueness: { scope: :condominium_id }


  def full_address
    [address_line, commune&.name, city&.name, region&.name, postal_code].compact.join(', ')
  end


  # Validación: la torre debe estar en la misma ubicación que su condominio
  validate :location_integrity

  private
  def location_integrity
    return unless condominium
    errors.add(:region, 'debe coincidir con la del condominio') if region_id != condominium.region_id
    errors.add(:city, 'debe coincidir con la del condominio') if city_id != condominium.city_id
    errors.add(:commune, 'debe coincidir con la del condominio') if commune_id != condominium.commune_id
  end
end
