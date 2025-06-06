module Cda
  class OffenceSummary < BaseModel
    has_one :laa_application, class_name: 'Cda::LaaApplication'
  end
end
