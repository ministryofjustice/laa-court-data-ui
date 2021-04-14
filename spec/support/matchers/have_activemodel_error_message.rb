# frozen_string_literal: true

require 'rspec/expectations'

# have_activemodel_error_message
# e.g.
# expect(model_instance).to have_activemodel_error_message(:first_name, "First name can\'t be blank")
#
RSpec::Matchers.define :have_activemodel_error_message do |attribute, message|
  match do |model_instance|
    model_instance.valid?
    model_instance.errors.messages[attribute.to_sym].include?(message)
  end

  description do
    "have activemodel error with message \"#{message}\""
  end

  failure_message do |model_instance|
    "expected activemodel error message: \"#{message}\" on #{attribute}\n" \
      "but received: #{model_instance.errors.messages[attribute.to_sym] || 'none'}"
  end
end
