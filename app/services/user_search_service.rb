class UserSearchService
  # Note that this search mechanism is inefficient for large data sets. If the number of users grows
  # beyond 1,000 it may be worth revisiting this in order to use a more advanced text search.
  def self.call(search_string)
    new(search_string).call
  end

  def initialize(search_string)
    @search_string = search_string
  end

  def call
    search_string.split.reduce(User) do |scope, token|
      add_filter(token, scope)
    end
  end

  private

  def add_filter(token, scope)
    scope.where(
      "first_name ILIKE :token OR last_name ILIKE :token OR email ILIKE :token OR username ILIKE :token",
      token:
    )
  end

  attr_reader :search_string
end
