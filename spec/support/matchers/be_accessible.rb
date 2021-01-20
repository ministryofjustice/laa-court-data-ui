# frozen_string_literal: true

require 'axe-rspec'

RSpec::Matchers.alias_matcher :be_accessible, :be_axe_clean
