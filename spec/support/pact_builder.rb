module PactBuilder
  def build_pact(consumer:, provider:, interactions:)
    {
      consumer: { name: consumer },
      provider: { name: provider },
      interactions: interactions,
      metadata: {
        pact: { specification: "4.0" }, # pact-ffi writes spec v4
        consumer_version: ENV.fetch("GITHUB_SHA", "dev"),
        branch: ENV.fetch("GITHUB_REF_NAME", "local"),
      },
    }
  end
end
