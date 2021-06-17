# frozen_string_literal: true

class Offence
  # include ActiveModel::Model

  attr_accessor :title, :legislation, :pleas,
                :mode_of_trial, :mode_of_trial_reasons

  def initialize(attributes = {})
    @title = attributes[:title]
    @legislation = attributes[:legislation]
    @please = attributes[:pleas]
    @mode_of_trial = attributes[:mode_of_trial]
    @mode_of_trial_reasons = attributes[:mode_of_trial_reasons]
  end
end
