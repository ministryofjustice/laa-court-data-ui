class UserSearchService
  # Note that this search mechanism is inefficient for large data sets. If the number of users grows
  # beyond 1,000 it may be worth revisiting this in order to use a more advanced text search.
  def self.call(search_model, default_scope)
    new(search_model, default_scope).call
  end

  def initialize(search_model, default_scope)
    @search_model = search_model
    @default_scope = default_scope
  end

  def call
    scope = default_scope

    if search_model.search_string.present?
      scope = search_model.search_string.split.reduce(scope) do |scope, token|
        add_filter(token, scope)
      end
    end

    filter_by_sign_in(scope)
  end

  def filter_by_sign_in(scope)
    if search_model.recent_sign_ins && !search_model.old_sign_ins
      scope = scope.where(last_sign_in_at: 3.months.ago..)
    elsif search_model.old_sign_ins && !search_model.recent_sign_ins
      scope = scope.where('last_sign_in_at IS NULL OR last_sign_in_at < ?', 3.months.ago)
    end

    scope
  end

  private

  def add_filter(token, scope)
    scope.where(
      "first_name ILIKE :token OR last_name ILIKE :token OR email ILIKE :token OR username ILIKE :token",
      token:
    )
  end

  attr_reader :search_model, :default_scope
end
