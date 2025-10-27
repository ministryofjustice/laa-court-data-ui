# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  let(:user) { create(:user, roles: ['caseworker']) }
  let(:password_reset_template) { '7314475f-62b0-41bf-8aff-768427cba456' }
  let(:unlock_instructions_template) { '18d9fde2-6ce6-48a9-8892-611733d69e26' }
  let(:password_change_template) { 'f72ca643-192a-476e-8f62-2a7e7c662e98' }
  let(:email_changed_template) { '6e720ef6-de86-4f78-ad71-786ad2687203' }

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
