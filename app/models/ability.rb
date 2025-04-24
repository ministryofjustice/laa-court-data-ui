# frozen_string_literal: true

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

    caseworker_abilities if user.caseworker?
    manager_abilities if user.manager?
    admin_abilities if user.admin?
  end

  private

  def caseworker_abilities
    can_search
    can_query_cdapi
    can_manage_links
    can_manage_self
  end

  def manager_abilities
    can_search
    can_query_cdapi
    can_manage_links
    can :manage, User
  end

  def admin_abilities
    caseworker_abilities
  end

  def can_search
    can %i[new create], SearchFilter
    can %i[new create], Search
    can %i[new create], CdApi::CaseSummaryService
    can %i[show], CourtDataAdaptor::Query::Defendant::ByUuid
    can %i[show], CdApi::SearchService
    can %i[show], CourtDataAdaptor::Query::Hearing
    can %i[show], CourtDataAdaptor::Resource::ApplicationSummary
  end

  def can_manage_links
    can :create, :link_maat_reference
  end

  def can_query_cdapi
    can %i[read], CdApi::CaseSummary
  end

  def can_manage_self
    can %i[show manage_password], User, id: user.id
  end
end
