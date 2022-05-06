# frozen_string_literal: true
module CdApi
  class HearingSummaryDecorator < BaseDecorator
    attr_accessor :day

    def defence_counsel_list
      # TODO: Add logic of attendance days for each defence
      return t('generic.not_available') if defence_counsels.blank?

      safe_join(defence_counsel_sentences, tag.br)
    end

    def hearing_days
      @hearing_days ||= decorate_all(object.hearing_days, CdApi::HearingDayDecorator)
    end

    private

    def decorated_defence_counsels
      decorate_all(defence_counsels, CdApi::DefenceCounselDecorator)
    end

    def defence_counsel_sentences
      decorated_defence_counsels&.map(&:name_and_status) || []
    end
  end
end
