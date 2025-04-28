# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::LaaReference do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it_behaves_like 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new }
  end

  describe '#save' do
    subject { instance.save }

    let(:instance) { described_class.new }
    let(:laa_reference_path) { %r{.*/api/internal/v1/laa_reference} }

    before { stub_request(:post, laa_reference_path) }

    it 'posts link request' do
      instance.save
      expect(a_request(:post, laa_reference_path)).to have_been_made.once
    end
  end
end
