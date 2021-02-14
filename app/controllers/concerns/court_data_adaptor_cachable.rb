# frozen_string_literal: true

module CourtDataAdaptorCachable
  extend ActiveSupport::Concern

  COURT_DATA_ADAPTOR_QUERY_CACHE_EXPIRY = 20.minutes

  included do
    def cached_search_call(query)
      Rails.cache.fetch(court_data_adaptor_resource_cache_key(query),
                        expires_in: COURT_DATA_ADAPTOR_QUERY_CACHE_EXPIRY) do
        query.call
      end
    end

    def court_data_adaptor_resource_cache_key(resource)
      "#{parameterized_name(resource)}-#{params.values.join('-')}"
    end

    def cached_search_execute(query)
      Rails.cache.fetch(court_data_adaptor_search_cache_key(query),
                        expires_in: COURT_DATA_ADAPTOR_QUERY_CACHE_EXPIRY) do
        query.execute
      end
    end

    def court_data_adaptor_search_cache_key(search)
      "#{parameterized_name(search.send(:query))}-#{params.values.join('-')}"
    end

    private

    def parameterized_name(object)
      object.class.to_s.parameterize
    end
  end
end
