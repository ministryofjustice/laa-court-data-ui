# frozen_string_literal: true

module HearingHelper
  def paginator(...)
    HearingPaginator.new(...)
  end

  def earliest_day_for(hearing)
    hearing&.hearing_days&.map(&:to_datetime)&.min
  end

  def transform_and_sanitize(text)
    text_with_converted_crlf = convert_crlf_to_html(text)
    sanitize(text_with_converted_crlf, tags: %w[br p])
  end

  private

  def convert_crlf_to_html(text)
    simple_format(text, {}, wrapper_tag: 'span')
  end
end
