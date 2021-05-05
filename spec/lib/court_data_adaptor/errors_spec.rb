# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Errors do
  it { is_expected.to be_const_defined :Error }
  it { is_expected.to be_const_defined :BadRequest }
  it { is_expected.to be_const_defined :UnprocessableEntity }

  describe CourtDataAdaptor::Errors::BadRequest do
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

  describe CourtDataAdaptor::Errors::UnprocessableEntity do
    subject(:instance) { described_class.new(msg, response) }

    let(:msg) { 'my custom bad request message' }
    let(:response_klass) { Struct.new(:status, :body) }
    let(:response) do
      response_klass.new(422, { field: %w[error1 error2] })
    end

    it { is_expected.to respond_to :response, :status, :errors }

    describe '#status' do
      subject { instance.status }

      it 'returns response status' do
        is_expected.to be 422
      end
    end

    describe '#errors' do
      subject { instance.errors }

      it 'returns response body' do
        is_expected.to match(field: %w[error1 error2])
      end
    end
  end
end
