# frozen_string_literal: true

class UnlinkReason < ApplicationRecord
  def self.ordered
    all.sort_by { |r| [r.description == 'Other' ? 1 : 0, r.code] }
  end

  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
