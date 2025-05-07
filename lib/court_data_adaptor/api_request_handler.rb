module CourtDataAdaptor
  class ApiRequestHandler
    def self.call(env)
      case env.response.status
      when 500
        raise CourtDataAdaptor::Errors::InternalServerError.new('Internal server error', env.response)
      when 400
        raise CourtDataAdaptor::Errors::BadRequest.new('Bad request', env.response)
      when 422
        raise CourtDataAdaptor::Errors::UnprocessableEntity.new('Unprocessable entity', env.response)
      when 424
        raise CourtDataAdaptor::Errors::ClientError.new('Client error', env.response)
      end
    end
  end
end
