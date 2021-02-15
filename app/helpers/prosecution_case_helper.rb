# frozen_string_literal: true

module ProsecutionCaseHelper
  def sorter(*args)
    HearingSorter.new(*args)
  end
end
