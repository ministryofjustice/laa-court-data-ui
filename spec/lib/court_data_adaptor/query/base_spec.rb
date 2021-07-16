# frozen_string_literal: true

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

  describe '.call' do
    subject(:call) { test_class.call('whatever') }

    let(:instance) { instance_double(test_class) }

    before do
      allow(test_class).to receive(:new).and_return instance
      allow(instance).to receive(:call)
      call
    end

    it 'initializes new instance with args' do
      expect(test_class).to have_received(:new).with('whatever', {})
    end

    it 'sends #call to instance' do
      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    subject(:call) { described_class.new('whatever').call }

    it { expect { call }.to raise_error StandardError, /Implement in subclass/ }
  end
end
