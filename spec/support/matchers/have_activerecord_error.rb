# frozen_string_literal: true

require 'rspec/expectations'

# have_activerecord_error
# e.g.
# expect(model_isntance).to have_activerecord_error(:first_name, "First name can\'t be blank")
#
RSpec::Matchers.define :have_activerecord_error do |attribute, message|
  match do |model_instance|
    model_instance.valid?
    model_instance.errors.messages[attribute.to_sym].include?(message)
  end

  description do
    'have activerecord error'
  end

  failure_message do |model_instance|
    if model_instance.errors.messages[attribute.to_sym].empty?
      msg = "expected activerecord error message on #{attribute} but found none."
    else model_instance.errors.messages[attribute.to_sym].include?(message)
      msg = "expected activerecord error message: \"#{message}\" on #{attribute}\n" +
            "but received: #{model_instance.errors.messages[attribute.to_sym]}"
    end
    msg
  end
end
