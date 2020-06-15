# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback, type: :model do
  it { is_expected.to validate_presence_of(:comment) }

  it {
    is_expected.to validate_inclusion_of(:rating).in_array(('1'..'5').to_a)
                                                 .with_message(/Please select a valid rating/)
  }

  it { is_expected.not_to validate_presence_of(:email) }
end
