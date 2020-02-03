# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource do
  it { is_expected.to be_const_defined :Error }
  it { is_expected.to be_const_defined :NotFound }
end
