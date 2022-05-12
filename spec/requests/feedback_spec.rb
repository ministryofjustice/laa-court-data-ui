# frozen_string_literal: true

RSpec.describe 'feedback', type: :request do
  let(:user) { create(:user) }
  let(:message_delivery) { instance_double(FeedbackMailer::MessageDelivery) }

  before do
    sign_in user
  end

  context 'when clicking the feedback link', type: :request do
    before { get '/feedback/new' }

    it { expect(response).to render_template('feedback/new') }
  end

  context 'when submitting feedback' do
    before do
      allow(FeedbackMailer).to receive(:notify).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later!)
      allow_any_instance_of(FeedbackController).to receive(:environment).and_return 'test'
      post '/feedback', params: feedback_params
    end

    context 'with valid params' do
      let(:feedback_params) do
        {
          feedback:
            {
              comment: 'A feedback comment',
              rating: '1',
              email: 'feedback.user@example.com'
            }
        }
      end

      it 'supplies personalisation' do
        expect(FeedbackMailer).to have_received(:notify)
          .with({ comment: 'A feedback comment',
                  rating: '1',
                  email: 'feedback.user@example.com',
                  environment: 'test' })
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/Your feedback has been submitted/)
      end

      it { expect(response).to redirect_to authenticated_root_path }
    end

    context 'with invalid params' do
      let(:feedback_params) do
        {
          feedback:
            {
              comment: 'A feedback comment',
              email: 'feedback.user@example.com'
            }
        }
      end

      it { expect(response).to render_template('feedback/new') }
      it { expect(response.body).to include('Choose a rating') }
    end
  end
end
