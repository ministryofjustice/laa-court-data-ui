module CourtDataAdaptor
  class ApiRequestHandler
    def self.call(env)
      case env.response.status
      when 400
        raise CourtDataAdaptor::Errors::BadRequest.new('Bad request', env.response)
      when 422
        raise CourtDataAdaptor::Errors::UnprocessableEntity.new('Unprocessable entity', env.response)
      end
    end
  end
end
