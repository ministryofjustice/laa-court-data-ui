# frozen_string_literal: true

RSpec.describe 'feedback', type: :request do
  let(:message_delivery) { instance_double(FeedbackMailer::MessageDelivery) }

  describe 'when clicking the feedback link', type: :request do
    before { get '/feedback/new' }

    it 'renders feedback/new' do
      expect(response).to render_template('feedback/new')
    end
  end

  describe 'Create feedback', type: :request do
    let(:feedback_params) do
      {
        feedback:
          {
            comment: 'A feedback comment',
            rating: 1,
            email: 'feedback.user@example.com'
          }
      }
    end

    before do
      allow(FeedbackMailer).to receive(:notify).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later!)
      post '/feedback', params: feedback_params
    end

    it 'sends feedback email' do
      expect(FeedbackMailer).to have_received(:notify)
    end

    it 'flashes notice' do
      expect(flash.now[:notice]).to match(/Your feedback has been submitted/)
    end
  end
end
