# frozen_string_literal: true

# rubocop:disable Style/OptionalBooleanParameter

module CourtDataApiResource
  attr_accessor :active_record_fields_set

  def connection(refresh = false)
    set_my_active_record_fields unless active_record_fields_set
    super(refresh)
  end

  def site
    set_my_active_record_fields unless active_record_fields_set
    super
  end

  def set_my_active_record_fields
    self.site = Rails.configuration.x.court_data_api_config.uri
  end
end

# rubocop:enable Style/OptionalBooleanParameter
