# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  let(:user) { create(:user, roles: ['caseworker']) }
  let(:password_reset_template) { '7314475f-62b0-41bf-8aff-768427cba456' }
  let(:unlock_instructions_template) { '18d9fde2-6ce6-48a9-8892-611733d69e26' }
  let(:password_change_template) { 'f72ca643-192a-476e-8f62-2a7e7c662e98' }
  let(:email_changed_template) { '6e720ef6-de86-4f78-ad71-786ad2687203' }

  describe 'Reset Password Instructions Email' do
    subject(:mail) { described_class.reset_password_instructions(user, 'fake_token') }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq([user.email.to_s])
    end

    it 'sets the personalisation' do
      expect(
        mail.govuk_notify_personalisation.keys.sort
      ).to eq %i[edit_password_url password_reset_url token_expiry_days user_full_name]
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq password_reset_template
    end
  end

  describe 'Unlock Instructions Email' do
    subject(:mail) { described_class.unlock_instructions(user, 'fake_token') }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq([user.email.to_s])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq %i[unlock_url user_full_name]
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq unlock_instructions_template
    end
  end

  describe 'Password Changed Email' do
    subject(:mail) { described_class.password_change(user) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq([user.email.to_s])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq %i[user_full_name]
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq password_change_template
    end
  end

  describe 'Email Changed Email' do
    subject(:mail) { described_class.email_changed(user) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      user.update!(email: 'updated@example.com', email_confirmation: 'updated@example.com')
      expect(mail.to).to eq([user.email_before_last_save.to_s])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq %i[user_full_name user_new_email]
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq email_changed_template
    end
  end
end
