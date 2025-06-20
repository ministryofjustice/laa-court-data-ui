module Cda
  class ProsecutionCaseSearch < BaseModel
    self.element_name = "prosecution_case"
    has_many :results, class_name: 'Cda::ProsecutionCase'

    def self.create(filter_params)
      http_response = post('/', nil, { filter: filter_params }.to_json)
      new(JSON.parse(http_response.body))
    end
  end
end
