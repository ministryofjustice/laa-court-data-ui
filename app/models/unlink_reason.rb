# frozen_string_literal: true

class UnlinkReason < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
