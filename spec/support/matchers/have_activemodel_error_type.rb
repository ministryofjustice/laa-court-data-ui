# frozen_string_literal: true

require 'rspec/expectations'

# have_activemodel_error_type
# e.g.
# expect(model_instance).to have_activemodel_error_type(:first_name, :too_short)
#
RSpec::Matchers.define :have_activemodel_error_type do |attribute, error_type|
  match do |model_instance|
    model_instance.valid?
    errors_for(model_instance, attribute).map(&:type).include?(error_type)
  end

  def errors_for(model_instance, attribute)
    model_instance.errors.select { |err| err.attribute.eql?(attribute) }
  end

  description do
    "have activemodel error of type \"#{error_type}\" on #{attribute}"
  end

  failure_message do
    "expected activemodel error type: \"#{error_type}\" on #{attribute}\n" \
      "but received: #{errors_for(attribute).map(&:type) || 'none'}"
  end
end
