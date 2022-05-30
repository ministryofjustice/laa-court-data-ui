# frozen_string_literal: true

module CdApi
  class HearingDecorator < BaseDecorator
    @cracked_ineffective_trial ||= decorate(object&.cracked_ineffective_trial)
  end
end
