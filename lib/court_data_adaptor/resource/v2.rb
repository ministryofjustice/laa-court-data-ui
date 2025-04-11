module CourtDataAdaptor
  module Resource
    class V2 < Base
      API_VERSION = 2
      include ResourceConfiguration

      class Parser
        def self.parse(klass, response)
          JsonApiClient::ResultSet.new([klass.new(response.body)])
        end
      end

      self.parser = Parser
    end
  end
end
