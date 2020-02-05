module FakeCourtDataAdaptor
  module Search
    class ProsecutionCase
      def initialize
      end

      def where(query = {})
        data = all['data']
        data.keep_if do |item|
          matches?(query, item)
        end
        { data: data }.to_json
      end

      def all
        @all ||= JSON.parse(Data::ProsecutionCase.all)
      end

      def matches?(query, item)
        result = false
        query.each do |attribute, terms|
          result = item.dig('attributes', attribute).match?(%r{#{terms}}i)
          break if result
        end
        result
      end
    end
  end
end
