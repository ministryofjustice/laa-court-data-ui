module Cda
  class HearingRepullBatch < BaseModel
    validates :maat_ids, presence: true
  end
end
