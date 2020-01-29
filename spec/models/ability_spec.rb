# frozen_string_literal: true

require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(themself) }

  let(:other_user) { create(:user, roles: ['caseworker']) }

  context 'when no user' do
    let(:themself) { nil }

    it { is_expected.not_to be_able_to(%i[new create], SearchFilter) }
    it { is_expected.not_to be_able_to(%i[new create], Search) }
    it { is_expected.not_to be_able_to(:manage, User) }
  end

  context 'when is a caseworker' do
    let(:themself) { create(:user, roles: ['caseworker']) }

    it { is_expected.to be_able_to(%i[new create], SearchFilter) }
    it { is_expected.to be_able_to(%i[new create], Search) }
    it { is_expected.to be_able_to(%i[show manage_password], themself) }
    it { is_expected.not_to be_able_to(%i[edit update destroy], themself) }

    it {
      is_expected.not_to \
        be_able_to(
          %i[show new create edit update manage_password destroy],
          other_user
        )
    }
  end

  context 'when is a manager' do
    let(:themself) { create(:user, roles: ['manager']) }

    it { is_expected.to be_able_to(:manage, themself) }
    it { is_expected.to be_able_to(:manage, other_user) }
  end
end
