# frozen_string_literal: true

require 'cancan/matchers'

RSpec.configure do |config|
  config.alias_it_behaves_like_to :it_is_able_to, 'is able to'
end

RSpec.shared_examples 'perform search' do
  it { is_expected.to be_able_to(%i[new create], SearchFilter) }
  it { is_expected.to be_able_to(%i[new create], Search) }
end

RSpec.shared_examples 'manage themselves only' do
  it { is_expected.to be_able_to(%i[show manage_password], themself) }
  it { is_expected.not_to be_able_to(%i[edit update destroy], themself) }
end

RSpec.shared_examples 'not manage others' do
  it {
    is_expected.not_to \
      be_able_to(
        %i[show new create edit update manage_password destroy],
        other_user
      )
  }
end

RSpec.fdescribe Ability, type: :model do
  subject(:ability) { described_class.new(themself) }

  let(:other_user) { create(:user, roles: ['caseworker']) }

  context 'when no user' do
    let(:themself) { nil }

    it { is_expected.not_to be_able_to(:manage, User) }
    it { is_expected.not_to be_able_to(%i[new create], SearchFilter) }
    it { is_expected.not_to be_able_to(%i[new create], Search) }
  end

  context 'when a caseworker' do
    let(:themself) { create(:user, roles: ['caseworker']) }

    it_is_able_to 'manage themselves only'
    it_is_able_to 'not manage others'
    it_is_able_to 'perform search'
  end

  context 'when a manager' do
    let(:themself) { create(:user, roles: ['manager']) }

    it { is_expected.to be_able_to(:manage, themself) }
    it { is_expected.to be_able_to(:manage, other_user) }
    it_is_able_to 'perform search'
  end

  context 'when an admin' do
    let(:themself) { create(:user, roles: ['admin']) }

    it_is_able_to 'manage themselves only'
    it_is_able_to 'not manage others'
    it_is_able_to 'perform search'
  end
end
