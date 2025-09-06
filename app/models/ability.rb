# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  
    # user ||= User.new

    # if user.persisted?
    #   user.roles.includes(:permissions).each do |role|
    #     role.permissions.each do |p|
    #       can p.action.to_sym, p.subject_class.safe_constantize || :all
    #     end
    #   end
    # else
    #   # Invitado (si quieres algo)
    #   # can :read, :all
    # end
    
    user ||= User.new # invitado


    if user.has_role?(:admin)
      can :manage, :all
    else
      # Ajustar según roles adicionales (conserje, residente, etc.)
      can :read, Condominium
      can :read, Unit
    end
  end
end
