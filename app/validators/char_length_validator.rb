# frozen_string_literal: true

class CharLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || char_length(value) >= options[:minimum]

    record.errors.add(attribute, options[:message] || :too_short, count: options[:minimum])
  end

  def char_length(value)
    value.squish.tr("\s+", '').length
  end
end
