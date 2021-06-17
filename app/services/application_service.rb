# frozen_string_literal: true

class ApplicationService
  def self.call(...)
    new(...).call
  end

  def call; end

  private

  def initialize(*args, &block); end
end
