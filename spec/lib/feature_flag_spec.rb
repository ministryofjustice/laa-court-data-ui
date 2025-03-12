# frozen_string_literal: true

require 'feature_flag'

RSpec.describe FeatureFlag do
  context 'when environment variable is not set' do
    before do
      ENV['TEST_VAR'] = nil
    end

    it 'returns false' do
      expect(described_class.enabled?(:test_var)).to be false
    end
  end

  context 'when environment variable is set to true' do
    before do
      ENV['TEST_VAR'] = 'true'
    end

    it 'returns true' do
      expect(described_class.enabled?(:test_var)).to be true
    end
  end

  context 'when environment variable is set to false' do
    before do
      ENV['TEST_VAR'] = 'false'
    end

    it 'returns false' do
      expect(described_class.enabled?(:test_var)).to be false
    end
  end
end
