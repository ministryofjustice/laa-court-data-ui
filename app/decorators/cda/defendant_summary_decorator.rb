module Cda
  class DefendantSummaryDecorator < BaseDecorator
    def linked?
      maat_reference.present? && maat_reference.first != 'Z'
    end

    def maat_reference
      different_maats = offence_summaries.map { |os| os.laa_application.try(:reference) }.uniq

      if different_maats.count > 1
        # There is an HMCTS bug where sometimes a defendant is assigned the wrong MAAT ID in one of
        # their offences. If this has happened, then the total number of different MAATs (including nulls)
        # will be > 1.
        Rails.logger.warn("Defendant #{id} has multiple MAAT IDs - #{different_maats.to_sentence}")
        "Not available"
      else
        different_maats.first
      end
    end
  end
end
