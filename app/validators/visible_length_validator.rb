# frozen_string_literal: true

class VisibleLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value && length_of(value) >= options[:minimum]

    record.errors.add(attribute, (options[:message] || :too_short), count: options[:minimum])
  end

  def length_of(value)
    value.squish.tr("\s+", '').length
  end
end
