module Cda
  class Defendant < BaseModel
    def name
      [first_name, middle_name, last_name].filter_map(&:presence).join(" ")
    end
  end
end
