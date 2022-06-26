# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # if user.present?
    #   if user.role.name == 'admin'
    #     can :manage, :all
    #   else
    #     can :create, ModelName
    #     can :read, ModelName
    #   end
    # else
    #   can :read, :all
    # end
  end
end
