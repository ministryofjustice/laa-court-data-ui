# frozen_string_literal: true

module TagsHelper
  def case_type_tag(case_type, text: nil)
    return if case_type.blank?

    mapping = {
      "T" => { text: "Trial", colour: "blue" },
      "S" => { text: "Breach/POCA", colour: "yellow" },
      "A" => { text: "Appeal", colour: "purple" },
    }

    key = case_type.to_s.upcase
    tag_info = mapping[key]

    if tag_info
      govuk_tag(text: text || tag_info[:text], colour: tag_info[:colour])
    else
      govuk_tag(text: text || key, colour: "grey")
    end
  end
end
