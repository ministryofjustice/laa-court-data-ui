# frozen_string_literal: true

module Cda
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
      hearing.hearing_days.first.sitting_day.to_fs(:day_month_year)
    end
  end
end
