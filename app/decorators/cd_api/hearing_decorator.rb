# frozen_string_literal: true

module CdApi
  class HearingDecorator < BaseDecorator
    def cracked_ineffective_trial
      @cracked_ineffective_trial ||= decorate(object.hearing.cracked_ineffective_trial,
                                              CdApi::CrackedIneffectiveTrialDecorator)
    end
  end
end
