module Cda
  class ProsecutionCase < BaseModel
    has_many :defendant_summaries, class_name: 'Cda::Defendant'
  end
end
