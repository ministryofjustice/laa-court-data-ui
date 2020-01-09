# frozen_string_literal: true

class Search
  include ActiveModel::Model

  attr_writer :filter
  attr_accessor :query

  def filter
    @filter || :case_number
  end

  def filters
    self.class.filters
  end

  def self.filters
    [
      SearchFilter.new(id: :case_number, name: 'By case number', description: nil),
      SearchFilter.new(id: :defendant, name: 'By defendant', description: 'Name or MAAT reference')
    ]
  end

  def execute
    ['first result from CP', 'second result from CP']
  end
end
