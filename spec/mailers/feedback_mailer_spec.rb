# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  let(:feedback_template) { '5fcd84b1-8d05-4b6c-86a8-9fc391efa754' }
  let(:comment) { 'A feedback comment' }
  let(:email) { 'feedback.user@example.com' }
  let(:rating) { 1 }

  describe 'Feedback Email' do
    subject(:mail) { described_class.notify(comment, email, rating) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'sets the personalisation' do
      expect(
        mail.govuk_notify_personalisation.keys.sort
      ).to eq %i[comment email rating]
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end
  end
end
