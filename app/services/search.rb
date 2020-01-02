class Search
  def initialize(**options)
    @query = options[:query]
    @filter = options[:filter]
  end

  def call
    ["first result from CP","second result from CP"]
  end
end
