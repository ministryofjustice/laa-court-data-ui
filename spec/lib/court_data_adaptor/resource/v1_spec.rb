# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::V1, :vcr do
  # rubocop:disable Style/ClassAndModuleChildren, RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
  class CourtDataAdaptor::Resource::MockResource < described_class
    acts_as_resource self
  end
  # rubocop:enable Style/ClassAndModuleChildren, RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock

  let(:mock_resource_endpoint) do
    [ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil), 'mock_resources'].join('/')
  end

  describe CourtDataAdaptor::Resource::MockResource do
    it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
      let(:klass) { described_class }
      let(:instance) { described_class.new }
    end

    include_examples 'court_data_adaptor resource callbacks' do
      let(:instance) { described_class.new }
    end

    it_behaves_like 'court_data_adaptor resource object', test_class: described_class

    describe 'request headers' do
      before do
        stub_request(:get, mock_resource_endpoint)
        described_class.all
      end

      it 'adds jsonapi media type Content-Type' do
        expect(
          a_request(:get, mock_resource_endpoint)
          .with(headers: { 'Content-Type' => 'application/vnd.api+json' })
        ).to have_been_made.once
      end

      it 'adds jsonapi media type Accepts' do
        expect(
          a_request(:get, mock_resource_endpoint)
          .with(headers: { 'Accept' => 'application/vnd.api+json' })
        ).to have_been_made.once
      end

      # TODO: Should we customize user agent (court-data-adaptor-client-v1-x.x.x, for example)
      it 'adds Faraday version User-Agent' do
        expect(
          a_request(:get, mock_resource_endpoint)
        .with(headers: { 'User-Agent' => /Faraday v1.\d{1,2}.\d{1,2}/ })
        ).to have_been_made.once
      end

      it 'adds OAuth2 Authorization: Bearer token' do
        expect(
          a_request(:get, mock_resource_endpoint)
        .with(headers: { 'Authorization' => /Bearer .*/ })
        ).to have_been_made.once
      end
    end

    describe 'connection options' do
      context 'when bad request responses' do
        before do
          stub_request(:get, mock_resource_endpoint)
            .to_return(
              status: 400,
              body: { field: %w[error1 error2] }.to_json
            )
        end

        it 'applies custom handler' do
          expect { described_class.all }.to \
            raise_error CourtDataAdaptor::Errors::BadRequest, 'Bad request'
        end
      end

      context 'when unprocessable entity response' do
        before do
          stub_request(:get, mock_resource_endpoint)
            .to_return(
              status: 422,
              body: { field: %w[error1 error2] }.to_json
            )
        end

        it 'applies custom handler' do
          expect { described_class.all }.to \
            raise_error CourtDataAdaptor::Errors::UnprocessableEntity, 'Unprocessable entity'
        end
      end
    end
  end
end
