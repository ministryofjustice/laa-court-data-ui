# frozen_string_literal: true

class UnlinkReason < ApplicationRecord
  OTHER_REASON_CODE = 7

  def text_required?
    code == OTHER_REASON_CODE
  end

  def self.ordered
    all.sort_by { |r| [r.text_required? ? 1 : 0, r.code] }
  end

  validates :code, presence: true, uniqueness: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
