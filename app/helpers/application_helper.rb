# frozen_string_literal: true

module ApplicationHelper
  def service_name
    'Common platform UI'
  end

  def page_title(title = nil)
    content_for :page_title, title || contextual_title
  end

  def contextual_title
    page_title [controller_name, action_name].join(' ').titleize
  end
end
