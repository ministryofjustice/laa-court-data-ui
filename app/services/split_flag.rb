# frozen_string_literal: true

class SplitFlag
  class << self
    def on?(key, split_name, config = {})
      get_treatment(key, split_name, config) == 'on'
    end

    private

    def get_treatment(key, split_name, config = {})
      client.get_treatment(key, split_name, config)
    end

    def client
      Rails.configuration.split_client
    end
  end
end
