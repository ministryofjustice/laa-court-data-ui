# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  def hearings
    @hearings ||= decorate_all(object.hearings)
  end

  attr_accessor :sort_order

  def sorted_hearings_with_day
    Enumerator.new do |enum|
      sorted_hearings.each do |hearing|
        sorted_hearing(hearing).each do |day|
          hearing.day = day
          enum.yield(hearing)
        end
      end
    end
  end

  def cracked?
    hearings.map { |h| h.cracked_ineffective_trial&.cracked? }.any?
  end

  private

  def sorted_hearings
    sorted_hearings = case sort_order
                      when /^type/
                        hearings.sort_by(&:hearing_type)
                      when /^provider/
                        hearings.sort_by(&:provider_list)
                      else
                        hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) }
                      end
    order_by_asc_or_desc(sorted_hearings)
    sorted_hearings
  end

  def order_by_asc_or_desc(sorted_hearings)
    sorted_hearings.reverse! if sort_order&.include? 'desc'
  end

  def sorted_hearing(hearing)
    if sort_order.eql?('date_desc')
      hearing.hearing_days.map(&:to_datetime).sort.reverse
    else
      hearing.hearing_days.map(&:to_datetime).sort
    end
  end
end
