# frozen_string_literal: true

RSpec.describe 'feedback', type: :request do
  let(:message_delivery) { instance_double(FeedbackMailer::MessageDelivery) }

  context 'when clicking the feedback link', type: :request do
    before { get '/feedback/new' }

    it 'renders feedback/new' do
      expect(response).to render_template('feedback/new')
    end
  end

  context 'when submitting feedback', type: :request do
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

    before do
      allow(FeedbackMailer).to receive(:notify).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later!)
      allow_any_instance_of(FeedbackController).to receive(:environment).and_return 'test'
      post '/feedback', params: feedback_params
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
  end
end
