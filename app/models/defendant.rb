# frozen_string_literal: true

class Defendant
  attr_accessor :id, :name, :date_of_birth, :national_insurance_number,
                :arrest_summons_number, :maat_reference, :offences

  def initialize(data = {})
    @data = data
    parsed_attributes
    parsed_included
    @id = JSON.parse(@data['data']['id'].to_json)
    @name = @parsed_attributes[:name]
    @date_of_birth = @parsed_attributes[:date_of_birth]
    @arrest_summons_number = @parsed_attributes[:arrest_summons_number]
    @national_insurance_number = @parsed_attributes[:national_insurance_number]
    @maat_reference = @parsed_attributes[:maat_reference]
    @offences = []
    included_offences
  end

  private

  def parsed_attributes
    @parsed_attributes ||= JSON.parse(@data['data']['attributes'].to_json, object_class: OpenStruct)
  end

  def parsed_included
    @parsed_included ||= JSON.parse(@data['included'].to_json)
  end

  def included_offences
    @parsed_included.each do |offence|
      offence_attributes = JSON.parse(offence['attributes'].to_json, object_class: OpenStruct)
      offences << Offence.new(offence_attributes)
    end
  end
end
