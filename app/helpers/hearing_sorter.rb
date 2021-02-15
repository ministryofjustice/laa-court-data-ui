# frozen_string_literal: true

class HearingSorter
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  # rubocop:disable Rails/HelperInstanceVariable
  def initialize(hearings, options = {})
    @hearings = hearings
    @sort_order = options.fetch(:sort_order, nil)
  end
  # rubocop:enable Rails/HelperInstanceVariable

  attr_reader :sort_order, :hearings

  def hearings_by_datetime
    if sort_order.eql?('date_desc')
      hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) }.reverse
    else
      hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) }
    end
  end

  def hearing_by_datetime(hearing)
    if sort_order.eql?('date_desc')
      hearing.hearing_days.map(&:to_datetime).sort.reverse
    else
      hearing.hearing_days.map(&:to_datetime).sort
    end
  end

  def hearings_with_day_by_datetime
    Enumerator.new do |enum|
      hearings_by_datetime.each do |hearing|
        hearing_by_datetime(hearing).each do |day|
          hearing.day = day
          enum.yield(hearing)
        end
      end
    end
  end

  #   def asc_link
  #     link_to("asc", params.merge(sort: :date_asc))
  #   end

  #   def desc_link
  #     link_to("desc", :sort => "date_desc")
  #   end
end
