module Cda
  class ProsecutionCaseSearch < BaseModel
    self.element_name = "prosecution_case"

    def self.execute(filter_params)
      http_response = post('/', nil, { filter: filter_params }.to_json)
      ProsecutionCaseSearchResponse.new(JSON.parse(http_response.body))
    end
  end
end
