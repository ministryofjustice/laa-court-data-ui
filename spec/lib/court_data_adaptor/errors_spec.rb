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

    describe "#error_string" do
      subject { instance.error_string }

      context 'when body is a string' do
        let(:response) do
          response_klass.new(422, "<html>Uh-oh...")
        end

        it 'returns a generic string' do
          is_expected.to eq "If this problem persists, please contact the IT Helpdesk on 0800 9175148."
        end
      end

      context 'when body is a hash in an unexpected format' do
        let(:response) do
          response_klass.new(422, { "error" => "Here is some error" })
        end

        it 'returns a generic string' do
          is_expected.to eq "If this problem persists, please contact the IT Helpdesk on 0800 9175148."
        end
      end

      context 'when body is a hash containing a deeply buried user facing string about defendant' do
        let(:cda_formatted_error_body) do
          { "error" => "Contract failed with: {:defendant_id=>[\"cannot be linked right now " \
                       "as we do not have all the required information\"]}" }
        end
        let(:response) do
          response_klass.new(422, cda_formatted_error_body)
        end

        it 'returns the completed string' do
          is_expected.to eq(
            "Defendant cannot be linked right now as we do not have all the required information"
          )
        end
      end

      context 'when body is a hash containing a deeply buried user facing string' do
        let(:cda_formatted_error_body) do
          { "error" => "Contract failed with: {:maat_reference=>[\"1111111 has no common platform data\"]}" }
        end
        let(:response) do
          response_klass.new(422, cda_formatted_error_body)
        end

        it 'returns the completed string' do
          is_expected.to eq(
            "MAAT reference 1111111 has no common platform data"
          )
        end
      end
    end
  end
end
