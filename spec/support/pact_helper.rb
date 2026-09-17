require "pact"
require "pact/rspec"

RSpec.shared_context "with laa-court-data-adaptor consumer pact" do
  has_http_pact_between "laa-court-data-ui", "laa-court-data-adaptor", opts: { pact_dir: "spec/pacts" }
end
