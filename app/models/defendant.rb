# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :id, :name, :date_of_birth, :national_insurance_number,
                :arrest_summons_number, :maat_reference
end
