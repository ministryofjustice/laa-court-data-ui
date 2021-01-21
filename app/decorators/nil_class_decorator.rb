# frozen_string_literal: true

# handles situations when `decorate` is called on a nil object
# using the "Null Object Pattern".
# note: simple delegator delegates most methods
# (blank?, present?) but not `nil?`, seemingly.
#
# See the application_helper#decorate method
# which depends on this.
#
class NilClassDecorator < BaseDecorator
  delegate :nil?, to: :object
end
