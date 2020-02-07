# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.fdescribe CourtDataAdaptor::Query::ProsecutionCase do
  subject { described_class }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'
end
