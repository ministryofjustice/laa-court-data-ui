# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource do
  it { is_expected.to be_const_defined :Error }
  it { is_expected.to be_const_defined :NotFound }
  it { is_expected.to be_const_defined :BadRequest }
end

RSpec.describe CourtDataAdaptor::Resource::BadRequest do
  subject(:instance) { described_class.new(msg, response) }

  let(:msg) { 'my custom bad request message' }
  let(:response_klass) { Struct.new(:status, :body) }
  let(:response) do
    response_klass.new(400, { field: %w[error1 error2] })
  end

  it { is_expected.to respond_to :response, :status, :errors }

  describe '#status' do
    subject { instance.status }

    it 'returns response status' do
      is_expected.to be 400
    end
  end

  describe '#errors' do
    subject { instance.errors }

    it 'returns response body' do
      is_expected.to match(field: %w[error1 error2])
    end
  end
end
