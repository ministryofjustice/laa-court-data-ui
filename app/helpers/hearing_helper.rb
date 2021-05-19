# frozen_string_literal: true

module HearingHelper
  def paginator(...)
    HearingPaginator.new(...)
  end

  def earliest_day_for(hearing)
    hearing&.hearing_days&.map(&:to_datetime)&.sort&.first
  end

  def transform_and_sanitize(event_note)
    note_with_converted_crlf = convert_crlf_to_html(event_note)
    sanitize(note_with_converted_crlf, tags: %w[br p])
  end

  private

  def convert_crlf_to_html(event_note)
    simple_format(event_note, {}, wrapper_tag: 'span')
  end
end
