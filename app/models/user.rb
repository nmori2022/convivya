# class User < ApplicationRecord
#   rolify
#   # Include default devise modules. Others available are:
#   # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
#   devise :database_authenticatable, :registerable,
#          :recoverable, :rememberable, :validatable
# end
class User < ApplicationRecord
  # Autenticación y recuperación con Devise
  devise :database_authenticatable, :registerable, 
          :recoverable, :rememberable, :validatable, :trackable


  # Roles con Rolify
  rolify


  # Un usuario administrador puede gestionar muchos condominios
  has_many :condominiums, foreign_key: :administrator_id, inverse_of: :administrator, dependent: :nullify
end