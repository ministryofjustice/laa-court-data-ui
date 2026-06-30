# frozen_string_literal: true

module SubjectsHelper
  def subject_back_label(application)
    case application.application_category
    when "appeal" then "Back to appellant"
    when "breach", "poca" then "Back to respondent"
    else "Back"
    end
  end
end
