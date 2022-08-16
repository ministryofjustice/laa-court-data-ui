module CdApi
  class OffenceSummary < BaseModel
    belongs_to :defendant
    has_one :laa_application, class_name: 'cd_api/laa_application'
  end
end
