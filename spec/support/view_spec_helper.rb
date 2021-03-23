# frozen_string_literal: true

# This is necessary in order to stub out ApplicationController
# methods that are declared as helpers.
#
# Declare the method here to raise an exception, and
# then in the spec, stub out the behaviour you need.
#
# Remember to include ViewSpecHelper in the spec, and call
# initialize_view_helpers, probably as a before(:each)
#

module ViewSpecHelper
  module ControllerViewHelpers
    def sort_column
      raise 'Stub sort_column if you want to test the behavior.'
    end

    def sort_direction
      raise 'Stub sort_column if you want to test the behavior.'
    end
  end

  def initialize_view_helpers(view)
    view.extend ControllerViewHelpers
  end
end
