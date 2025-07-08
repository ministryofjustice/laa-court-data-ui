require "rails_helper"

RSpec.describe UserSearchService do
  subject(:search_results) { described_class.call(query_string).to_a }

  let(:searched_user) do
    create(:user, first_name: 'Jane', last_name: 'Doe', username: 'j-doe', email: 'jane@example.com')
  end
  let(:unsearched_user) do
    create(:user, first_name: 'John', last_name: 'Smith', username: 'j-smith', email: 'john@example.com')
  end

  before do
    searched_user
    unsearched_user
  end

  context 'when searching by username' do
    let(:query_string) { 'j-doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by email' do
    let(:query_string) { 'jane@example.com' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by first name' do
    let(:query_string) { 'Jane' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by last name' do
    let(:query_string) { 'Doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by full name' do
    let(:query_string) { 'Jane Doe' }

    it { is_expected.to include(searched_user) }
    it { is_expected.not_to include(unsearched_user) }
  end

  context 'when searching by impossible combo' do
    let(:query_string) { 'Jane Smith' }

    it { is_expected.to be_empty }
  end
end
