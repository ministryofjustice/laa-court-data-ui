# frozen_string_literal: true

RSpec.shared_examples 'court_data_adaptor acts_as_resource object' do |options|
  it { expect(klass).to respond_to :acts_as_resource, :resource }
  it { expect(instance).to respond_to :resource }
  it { expect(instance).to respond_to :refresh_token_if_required! }

  it "acts as #{options[:resource]}" do
    expect(instance.resource).to eql options.fetch(:resource, described_class)
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
      is_expected.to eql ENV['COURT_DATA_ADAPTOR_API_URL']
    end
  end

  describe '.client' do
    subject { options[:test_class].client }

    it 'returns instance of client' do
      is_expected.to be_an_instance_of(CourtDataAdaptor::Client)
    end
  end
end
