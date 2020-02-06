# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Error < StandardError; end
    class NotFound < Error; end
  end
end
