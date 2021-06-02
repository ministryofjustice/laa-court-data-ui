# frozen_string_literal: true

class CourtApplicationDecorator < BaseDecorator
  def respondent_list
    return t('generic.not_available') if respondents.blank?

    safe_join(respondents.map(&:synonym), tag.br)
  end

  def applicant_synonym
    type.applicant_appellant_flag == true ? 'Applicant' : ''
  end
end
