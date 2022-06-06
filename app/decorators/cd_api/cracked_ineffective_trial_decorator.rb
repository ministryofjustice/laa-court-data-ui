# frozen_string_literal: true

module CdApi
  class CrackedIneffectiveTrialDecorator < BaseDecorator
    def cracked_on_sentence(hearing)
      t('cracked_ineffective_trial.cracked_on_sentence',
        type: type&.humanize,
        cracked_at: cracked_at(hearing))
    end

    def description_sentence
      "<strong>#{type&.humanize}</strong>: #{description}"
    end

    private

    def cracked_at(hearing)
      hearing.hearing_days.first.sitting_day.to_date.strftime('%d/%m/%Y')
    end
  end
end
