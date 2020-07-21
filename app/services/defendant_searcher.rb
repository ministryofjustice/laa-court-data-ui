# frozen_string_literal: true

class DefendantSearcher
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def initialize(search)
    @search = search
  end

  def call
    @search.execute.first
  end
end
