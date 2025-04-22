module CourtDataAdaptor
  module Resource
    # NOTE: To inherit from this base class you will need to subclass it,
    # and in the subclass first define an API_VERSION constant and
    # *then* include ResourceConfiguration. This is because JsonApiClient
    # hard-defines "site" as soon as the resource class is parsed, meaning
    # standard inheritance techniques don't work.
    class Base < JsonApiClient::Resource
      include JsonApiClient::Helpers::Callbacks
      include Configurable
      include ActsAsResource

      before_save do
        refresh_token_if_required!
      end

      VERSION = '0.0.1'.freeze
    end
  end
end
