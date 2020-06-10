# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::LaaReference do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class
end
