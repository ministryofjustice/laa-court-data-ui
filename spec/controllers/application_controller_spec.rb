# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  context "when appending data to the logs" do
    before do
      request.remote_ip = "1.0.0.1"
      request.user_agent = "RSpec user agent"
    end

    it "logs a message with user agent and remote ip" do
      events = capture_semantic_logger_events do
        get :index
      end

      expect(events).to include(
        a_semantic_logger_event(payload_includes: { remote_ip: "1.0.0.1", user_agent: "RSpec user agent" }),
      )
    end
  end
end
