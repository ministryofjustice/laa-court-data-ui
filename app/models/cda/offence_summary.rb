module Cda
  class OffenceSummary < BaseModel
    has_one :laa_application, class_name: 'Cda::LaaApplication'
    has_many :pleas, class_name: 'Cda::Plea'

    def maat_reference
      laa_application.try(:reference)
    end
  end
end
