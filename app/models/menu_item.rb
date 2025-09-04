class MenuItem < ApplicationRecord
    validates :name, :path, presence: true
    default_scope { order(position: :asc) }
end
