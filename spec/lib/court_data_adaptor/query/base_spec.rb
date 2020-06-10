# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Base do
  subject(:test_class) do
    Class.new(described_class) do
      acts_as_resource :nil_resource
    end
  end

  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: :nil_resource do
    let(:klass) { test_class }
    let(:instance) { test_class.new(nil) }
  end

  it_behaves_like 'court_data_adaptor query object'
end
