module Cda
  class Plea < BaseModel
    def date
      super.to_date
    end
  end
end
