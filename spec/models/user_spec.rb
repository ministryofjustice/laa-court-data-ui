# frozen_string_literal: true

RSpec.describe User, type: :model do
  subject(:user) do
    build(:user,
          email: 'john.smith@example.com',
          email_confirmation: 'john.smith@example.com',
          first_name: 'John',
          last_name: 'Smith',
          username: 'smit-j1')
  end

  # only attributes/methods that are additional to devise user
  it { is_expected.to respond_to(:first_name, :last_name, :login, :name, :roles, :email_confirmation) }

  it { is_expected.to validate_presence_of(:first_name).with_message(/Enter a first name/) }
  it { is_expected.to validate_presence_of(:last_name).with_message(/Enter a last name/) }

  context 'when validating email' do
    it { is_expected.to validate_presence_of(:email).with_message(/Enter an email address/) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message(/Email already taken/) }

    # see config/initializers/devise.rb
    context 'with upper case chars' do
      before do
        user.email = 'John.Smith@example.com'
        user.email_confirmation = 'John.Smith@example.com'
      end

      it 'downcases username during validation' do
        expect { user.valid? }.to \
          change(user, :email)
          .from('John.Smith@example.com')
          .to('john.smith@example.com')
      end
    end

    # see config/initializers/devise.rb
    context 'with whitespace chars' do
      before { user.email = '   john.smith@example.com   ' }

      it 'strips whitespace during validation' do
        expect { user.valid? }.to \
          change(user, :email)
          .from('   john.smith@example.com   ')
          .to('john.smith@example.com')
      end
    end
  end

  context 'when validating username' do
    it {
      is_expected.to \
        validate_presence_of(:username)
        .with_message(/Enter a username/)
    }

    it {
      is_expected.to \
        validate_uniqueness_of(:username)
        .case_insensitive
        .with_message(/Username already taken/)
    }

    it {
      is_expected.to \
        allow_value('bob-j', 'bobi-j', 'bobi-j1', 'a' * 10, '1' * 10)
        .for(:username)
    }

    it {
      is_expected.not_to \
        allow_value('bob@example.com', 'a' * 11, '1' * 11)
        .for(:username)
        .with_message(/Username format is invalid/)
    }

    # see config/initializers/devise.rb
    context 'with upper case chars' do
      before { user.username = 'Bob-J' }

      it 'downcases username during validation' do
        expect { user.valid? }.to \
          change(user, :username)
          .from('Bob-J')
          .to('bob-j')
      end
    end

    # see config/initializers/devise.rb
    context 'with whitespace chars' do
      before { user.username = '   bob-J ' }

      it 'strips whitespace during validation' do
        expect { user.valid? }.to \
          change(user, :username)
          .from('   bob-J ')
          .to('bob-j')
      end
    end
  end

  describe '#name' do
    subject { user.name }

    it 'returns "firstname lastname"' do
      is_expected.to eql 'John Smith'
    end
  end

  describe '#login' do
    subject { user.login }

    context 'when login has been set' do
      before { user.login = 'bobi-j' }

      it 'uses the login username provided' do
        is_expected.to eql 'bobi-j'
      end
    end

    context 'when no login set' do
      before { user.login = nil }

      context 'with user with username' do
        it 'uses the users username attribute' do
          is_expected.to eql 'smit-j1'
        end
      end

      context 'with user with no username' do
        before { user.username = nil }

        it 'uses the users email attribute' do
          is_expected.to eql 'john.smith@example.com'
        end
      end
    end
  end

  describe 'roles' do
    describe '.valid_roles' do
      subject { described_class.valid_roles }

      it 'returns all valid roles for class' do
        is_expected.to eq %w[caseworker manager admin data_analyst]
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
          raise_error ActiveRecord::RecordInvalid, /Email confirmation doesn't match Email/
      end

      it 'blank email confirmation raises error' do
        expect do
          user.update!(email: 'john.boy@example.com', email_confirmation: '')
        end.to \
          raise_error ActiveRecord::RecordInvalid, /Email confirmation can't be blank/
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

  describe '#send_devise_notification' do
    subject(:send_notification) { user.send_devise_notification(:my_test_email, :an_arg) }

    let(:devise_mailer) { instance_double(Devise::Mailer) }
    let(:mailer) { instance_double(ActionMailer::MessageDelivery) }
    let(:test_user) { user }

    before do
      allow(test_user).to receive(:devise_mailer).and_return(devise_mailer)
      allow(devise_mailer).to receive(:send).and_return(mailer)
      allow(mailer).to receive(:deliver_later)
      send_notification
    end

    it 'passes args through to devise mailer' do
      expect(devise_mailer).to have_received(:send).with(:my_test_email, user, :an_arg)
    end

    it 'uses `deliver_later`' do
      expect(mailer).to have_received(:deliver_later)
    end
  end
end
