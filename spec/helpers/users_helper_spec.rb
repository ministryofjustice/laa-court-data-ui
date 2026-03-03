# frozen_string_literal: true

RSpec.describe UsersHelper, type: :helper do
  describe '#feature_flag_options' do
    subject(:options) { helper.feature_flag_options }

    it 'returns an array of [key, label] pairs for each feature flag' do
      expect(options).to eq([['view_appeals', 'View appeals, breaches and POCA']])
    end
  end

  describe '#feature_flag_descriptions_for_user' do
    subject(:result) { helper.feature_flag_descriptions_for_user(user) }

    context 'when the user has no feature flags' do
      let(:user) { build(:user, feature_flags: []) }

      it { is_expected.to eq('None') }
    end

    context 'when the user has feature flags' do
      let(:user) { build(:user, feature_flags: ['view_appeals']) }

      it { is_expected.to eq('View appeals, breaches and POCA') }
    end
  end
end
