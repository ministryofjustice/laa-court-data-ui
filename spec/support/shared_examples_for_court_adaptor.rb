# frozen_string_literal: true

RSpec.shared_examples 'court_data_adaptor acts_as_resource object' do |options|
  it { expect(klass).to respond_to :acts_as_resource, :resource, :refresh_token_if_required! }
  it { expect(instance).to respond_to :resource, :refresh_token_if_required! }

  it "acts as #{options[:resource]}" do
    expect(instance.resource).to eql options[:resource]
  end
end

RSpec.shared_examples 'court_data_adaptor resource callbacks' do
  before do
    stub_request(:post, %r{.*/api/internal/v1/.*})
    allow(instance).to receive(:refresh_token_if_required!)
  end

  describe '#save' do
    before { instance.save }

    it 'calls token refresh' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end
  end

  describe '#update' do
    before { instance.update }

    it 'calls token refresh' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end
  end
end

RSpec.shared_examples 'court_data_adaptor query object' do
  it { is_expected.to respond_to :call }
  it { expect(subject.new(nil)).to respond_to(:call, :term, :term=, :dob, :dob=) }
end

RSpec.shared_examples 'court_data_adaptor resource object' do |options|
  describe '.site' do
    subject { options[:test_class].site }

    it 'returns environment specific configured court data uri' do
      is_expected.to eql ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil)
    end
  end

  describe '.client' do
    subject { options[:test_class].client }

    it 'returns instance of client' do
      is_expected.to be_an_instance_of(Cda::Client)
    end
  end
end
