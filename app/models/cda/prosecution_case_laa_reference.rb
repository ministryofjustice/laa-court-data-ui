module Cda
  class ProsecutionCaseLaaReference < BaseModel
    self.element_name = "laa_reference"

    def self.create!(laa_reference)
      post('', nil, { laa_reference: }.to_json)
    end

    def self.update!(laa_reference)
      patch(laa_reference[:defendant_id], nil, { laa_reference: }.to_json)
    end
  end
end
