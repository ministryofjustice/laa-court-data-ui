require "rails_helper"

RSpec.describe UserSearchService do
  subject(:search_results) { described_class.call(user_search, User).to_a }

  let(:user_search) do
    UserSearch.new(search_string:, recent_sign_ins:, old_sign_ins:, manager_role:, admin_role:)
  end
  let(:searched_user) do
    create(:user, first_name: 'Jane', last_name: 'Doe', username: 'j-doe', email: 'jane@example.com',
                  last_sign_in_at: 1.day.ago, roles: ['manager'])
  end
  let(:unsearched_user) do
    create(:user, first_name: 'John', last_name: 'Smith', username: 'j-smith', email: 'john@example.com',
                  last_sign_in_at: nil)
  end
  let(:recent_sign_ins) { false }
  let(:old_sign_ins) { false }
  let(:manager_role) { false }
  let(:admin_role) { false }
  let(:search_string) { nil }

  before do
    searched_user
    unsearched_user
  end

  context 'when searching by username' do
    let(:search_string) { 'j-doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by email' do
    let(:search_string) { 'jane@example.com' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by first name' do
    let(:search_string) { 'Jane' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by last name' do
    let(:search_string) { 'Doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by full name' do
    let(:search_string) { 'Jane Doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by impossible combo' do
    let(:search_string) { 'Jane Smith' }

    it { is_expected.to be_empty }
  end

  context 'when filtering by recent sign ins' do
    let(:recent_sign_ins) { true }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when filtering by old sign ins' do
    let(:old_sign_ins) { true }

    before do
      searched_user.update(last_sign_in_at: 4.months.ago)
      unsearched_user.update(last_sign_in_at: 1.day.ago)
    end

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when filtering by manager role' do
    let(:manager_role) { true }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when filtering by admin role' do
    let(:admin_role) { true }

    before do
      searched_user.update(roles: %w[manager admin])
    end

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end
end
