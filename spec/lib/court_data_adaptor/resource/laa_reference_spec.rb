# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::LaaReference do
  it_behaves_like 'court_data_adaptor resource object', test_class: described_class
end
