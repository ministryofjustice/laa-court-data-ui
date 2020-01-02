class CommonPlatformSearch
  def initialize(**options)
    @query = options[:query]
    @filter = options[:filter]
  end
end