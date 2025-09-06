class Permission < ApplicationRecord
    has_and_belongs_to_many :roles
    validates :action, :subject_class, presence: true
end
