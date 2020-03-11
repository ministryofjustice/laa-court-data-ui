# frozen_string_literal: true

# rubocop:disable Style/GuardClause
class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(init_user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
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
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    @user = init_user
    return if user.blank?

    alias_action :change_password, :update_password, to: :manage_password

    if user.caseworker?
      can_search
      can_manage_self
    end

    if user.manager?
      can_search
      can :manage, User
    end

    if user.admin?
      can_search
      can_manage_self
    end
  end

  private

  def can_search
    can %i[new create], SearchFilter
    can %i[new create], Search
  end

  def can_manage_self
    can %i[show manage_password], User, id: user.id
  end
end
# rubocop:enable Style/GuardClause
