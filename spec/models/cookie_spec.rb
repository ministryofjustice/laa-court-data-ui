# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cookie, type: :model do
  it { is_expected.to validate_presence_of(:analytics) }
  it { is_expected.to validate_inclusion_of(:analytics).in_array(%w[true false]) }
end
