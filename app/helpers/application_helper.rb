# frozen_string_literal: true

module ApplicationHelper
  include GovukDesignSystemHelper

  def service_name
    'View court data'
  end

  def l(date, options = {})
    super(date, options) if date
  end
end
