module Cda
  class ProsecutionCaseSearchResponse < BaseModel
    has_many :results, class_name: 'Cda::ProsecutionCase'
  end
end
