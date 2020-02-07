# frozen_string_literal: true

RSpec.describe CourtDataAdaptor::Query::Defendant do
  subject { described_class }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'
end
