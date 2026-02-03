module Cda
  class ProsecutionCaseLaaReference < BaseModel
    self.element_name = "laa_reference"

    # POST /api/internal/v2/laa_references
    def self.create!(laa_reference)
      post('', nil, { laa_reference: }.to_json)
    end

    # PUT /api/internal/v2/laa_references/:defendant_id
    def self.update!(laa_reference)
      patch(laa_reference[:defendant_id], nil, { laa_reference: }.to_json)
    end
  end
end
