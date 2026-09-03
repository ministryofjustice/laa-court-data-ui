# frozen_string_literal: true

RSpec::Matchers.define :have_hearing_sorter_link do |text:, column:, next_direction:, icon_direction:|
  match do |node|
    selector = "a.govuk-link--no-visited-state[href*='column=#{column}'][href*='direction=#{next_direction}']"
    return false unless node.has_css?(selector, text:)

    link = node.find(selector, text:, match: :first)
    link.has_css?("svg.#{icon_css_class(icon_direction)}")
  end

  failure_message do
    "expected page to have sorting link '#{text}' for column '#{column}' " \
      "with href direction '#{next_direction}' and svg '.#{icon_css_class(icon_direction)}'"
  end

  def icon_css_class(direction)
    case direction.to_s
    when "asc" then "up"
    when "desc" then "down"
    when "none" then "updown"
    else
      direction.to_s
    end
  end
end
