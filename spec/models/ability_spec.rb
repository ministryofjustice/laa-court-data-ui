# frozen_string_literal: true

require 'cancan/matchers'

RSpec.configure do |config|
  config.alias_it_behaves_like_to :is_able_to, 'is able to'
end

RSpec.shared_examples 'perform search' do
  it { is_expected.to be_able_to(%i[new create], SearchFilter) }
  it { is_expected.to be_able_to(%i[new create], Search) }
end

RSpec.shared_examples 'query v2 CDA' do
  it { is_expected.to be_able_to(%i[read], Cda::ProsecutionCase) }
end

RSpec.shared_examples 'link maat reference' do
  it { is_expected.to be_able_to(:create, :link_maat_reference) }
end

RSpec.shared_examples 'manage themselves only' do
  it { is_expected.to be_able_to(%i[show], themself) }
  it { is_expected.not_to be_able_to(%i[edit update destroy], themself) }
end

RSpec.shared_examples 'not manage others' do
  it {
    is_expected.not_to \
      be_able_to(
        %i[show new create edit update destroy],
        other_user
      )
  }
end

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(themself) }

  let(:other_user) { create(:user, roles: ['caseworker']) }

  context 'when no user' do
    let(:themself) { nil }

    it { is_expected.not_to be_able_to(:manage, User) }
    it { is_expected.not_to be_able_to(%i[new create], SearchFilter) }
    it { is_expected.not_to be_able_to(%i[new create], Search) }
    it { is_expected.not_to be_able_to(%i[read], Cda::ProsecutionCase) }
    it { is_expected.not_to be_able_to(:create, :link_maat_reference) }
  end

  context 'when a caseworker' do
    let(:themself) { create(:user, roles: ['caseworker']) }

    is_able_to 'manage themselves only'
    is_able_to 'not manage others'
    is_able_to 'perform search'
    is_able_to 'link maat reference'
    is_able_to 'query v2 CDA'
  end

  context 'when a manager' do
    let(:themself) { create(:user, roles: ['manager']) }

    it { is_expected.to be_able_to(:manage, themself) }
    it { is_expected.to be_able_to(:manage, other_user) }

    is_able_to 'perform search'
    is_able_to 'link maat reference'
    is_able_to 'query v2 CDA'
  end

  context 'when an admin' do
    let(:themself) { create(:user, roles: ['admin']) }

    is_able_to 'manage themselves only'
    is_able_to 'not manage others'
    is_able_to 'perform search'
    is_able_to 'link maat reference'
    is_able_to 'query v2 CDA'
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
