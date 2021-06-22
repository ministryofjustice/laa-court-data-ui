# frozen_string_literal: true

class Defendant < ApplicationRecord
  has_many :offences, dependent: :destroy

  accepts_nested_attributes_for :offences
end
