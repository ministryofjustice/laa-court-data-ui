# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::ActsAsResource, :concern do
  let(:test_class) do
    Class.new do
      include CourtDataAdaptor::ActsAsResource

      acts_as_resource :my_resource_class
    end
  end

  describe '.acts_as_resource' do
    before { test_class.acts_as_resource :funky_resource_class }

    it 'defines resource class constant on the class' do
      expect(test_class.resource).to be :funky_resource_class
    end
  end

  describe '.resource' do
    subject { test_class.resource }

    it { is_expected.to be :my_resource_class }
  end

  describe '#resource' do
    subject { test_class.new.resource }

    it { is_expected.to be :my_resource_class }
  end

  describe '.refresh_token_if_required!' do
    subject(:refresh) { test_class.refresh_token_if_required! }

    let(:resource) { class_double('MyResource') }
    let(:client) { instance_double(CourtDataAdaptor::Client) }

    before do
      conn = instance_double(JsonApiClient::Connection)
      allow(test_class).to receive(:resource).and_return(resource)
      allow(resource).to receive(:connection).and_yield(conn)
      allow(conn).to receive(:use)
      allow(resource).to receive(:client).and_return(client)
      allow(client).to receive(:bearer_token).and_return('test-token')
      refresh
    end

    it 'rebuilds connection' do
      expect(resource).to have_received(:connection).with(true)
    end

    it 'calls client bearer_token, which refreshes if required' do
      expect(client).to have_received(:bearer_token)
    end
  end

  describe '#refresh_token_if_required!' do
    subject(:refresh) { resource_instance.refresh_token_if_required! }

    let(:resource_instance) { test_class.new }

    before do
      allow(test_class).to receive(:refresh_token_if_required!)
    end

    it 'calls .refresh_token_if_required!' do
      resource_instance.refresh_token_if_required!
      expect(test_class).to have_received(:refresh_token_if_required!)
    end
  end
end
