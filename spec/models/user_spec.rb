# frozen_string_literal: true

RSpec.describe User, type: :model do
  let(:user) do
    build(:user,
          email: 'john.smith@example.com',
          first_name: 'John',
          last_name: 'Smith')
  end

  # only attributes/methods that are additional to devise user
  it { is_expected.to respond_to(:first_name, :last_name, :name, :roles, :email_confirmation) }

  describe '#name' do
    subject { user.name }

    it 'returns "firstname lastname"' do
      is_expected.to eql 'John Smith'
    end
  end

  describe 'roles' do
    describe '.valid_roles' do
      subject { described_class.valid_roles }

      it 'returns all valid roles for class' do
        is_expected.to eq %w[caseworker manager admin]
      end
    end

    describe '#roles' do
      subject { user.roles }

      let(:user) { build(:user, roles: %i[caseworker manager]) }

      it 'returns roles on user object' do
        is_expected.to eq %w[caseworker manager]
      end
    end
  end

  describe '#email' do
    let(:user) do
      create(:user,
             email: 'jim.bob@example.com',
             email_confirmation: 'jim.bob@example.com')
    end

    context 'when validating email' do
      it 'mismatching email confirmation raises error' do
        expect do
          user.update!(email: 'john.boy@example.com', email_confirmation: 'jim.bob@example.com')
        end.to \
          raise_error ActiveRecord::RecordInvalid, /Email confirmation doesn\'t match Email/
      end

      it 'blank email confirmation raises error' do
        expect do
          user.update!(email: 'john.boy@example.com', email_confirmation: '')
        end.to \
          raise_error ActiveRecord::RecordInvalid, /Email confirmation can\'t be blank/
      end
    end

    context 'when validating email after changing unrelated field' do
      it 'does not raise error' do
        expect do
          user.update(first_name: 'John', last_name: 'Boy')
        end.not_to \
          raise_error
      end
    end
  end
end
