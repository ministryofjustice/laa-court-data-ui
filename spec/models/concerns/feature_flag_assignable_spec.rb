# frozen_string_literal: true

RSpec.describe FeatureFlagAssignable, type: :concern do
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include FeatureFlagAssignable

      attr_accessor :feature_flags
    end
  end

  describe '.feature_flags' do
    it { expect(test_class.feature_flags).to match_array(%w[view_appeals]) }
  end

  describe '#validate_flags' do
    context 'when feature flag is not one of those allowed' do
      let(:object) { test_class.new(feature_flags: %i[random]) }

      it 'renders object invalid' do
        expect(object).not_to be_valid
      end

      it 'adds error to object' do
        object.valid?
        expect(object.errors[:feature_flags]).to include('random is not a valid feature flag')
      end
    end

    context 'when feature flag is blank' do
      let(:object) { test_class.new(feature_flags: ["", "view_appeals"]) }

      before { object.valid? }

      it 'removes the blank' do
        expect(object.feature_flags).to match_array(%w[view_appeals])
      end

      it 'then passes validation' do
        expect(object).to be_valid
      end
    end
  end

  describe '#feature_flag_enabled?' do
    subject(:output) { object.feature_flag_enabled?(:view_appeals) }

    context 'when feature flag is not one of those enabled' do
      let(:object) { test_class.new(feature_flags: []) }

      it { is_expected.to be false }
    end

    context 'when feature flag is enabled' do
      let(:object) { test_class.new(feature_flags: %i[view_appeals]) }

      it { is_expected.to be false }
    end
  end
end
