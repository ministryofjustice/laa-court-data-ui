class CommonPlatformSearch
  def initialize(**options)
    @query = options[:query]
    @filter = options[:filter]
  end

  def call
    # TODO: execute query against commonplatform
    # client = CommonPlatformConnecter.client
    # client.call(@query, @filter)
    ["result from CP"]
  end
end
