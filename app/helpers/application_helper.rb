# frozen_string_literal: true

module ApplicationHelper
  SearchOption = Struct.new(:id, :name, :description)

  def service_name
    'Common platform UI'
  end

  def page_title(title = nil)
    content_for :page_title, title || contextual_title
  end

  def contextual_title
    page_title [controller_name, action_name].join(' ').titleize
  end

  def search_options
    [
      SearchOption.new(:case_number, 'By case number'),
      SearchOption.new(:defendant, 'By defendant', 'Name or MAAT reference')
    ]
  end
end
