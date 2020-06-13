# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  let(:feedback_template) { '5fcd84b1-8d05-4b6c-86a8-9fc391efa754' }
  let(:comment) { 'A feedback comment' }
  let(:email) { 'feedback.user@example.com' }
  let(:rating) { 1 }
  let(:environment) { 'test' }

  describe '#notify' do
    subject(:mail) { described_class.notify(**args) }

    let(:args) { { email: email, rating: rating, comment: comment, environment: environment } }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient from config' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end

    context 'with personalisation' do
      it 'sets personalisation from args' do
        expect(
          mail.govuk_notify_personalisation
        ).to include(comment: comment, email: email, rating: rating, environment: environment)
      end

      context 'when no comment' do
        let(:args) { { email: email, rating: rating, environment: environment } }

        it 'sets comment to nil' do
          expect(
            mail.govuk_notify_personalisation
          ).to include(comment: nil, email: email, rating: rating, environment: environment)
        end
      end
    end
  end
end
