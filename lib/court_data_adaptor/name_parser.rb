# frozen_string_literal: true

module CourtDataAdaptor
  class NameParser
    def initialize(term)
      @term = term
    end

    attr_reader :term

    def parts
      return @parts if @parts
      terms = term.split

      first = terms.slice!(0)
      last = terms.slice!(-1)
      middle = terms.join(' ') unless terms.empty?
      @parts = {
        first: first,
        last: last,
        middle: middle
      }
    end

    def first
      parts[:first]
    end

    def last
      parts[:last]
    end

    def middle
      parts[:middle]
    end
  end
end
