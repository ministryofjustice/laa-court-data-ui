module Cda
  class Plea < BaseModel
    def date
      super.to_date
    end

    def user_facing_value
      value.humanize
    end
  end
end
