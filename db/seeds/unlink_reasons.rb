# frozen_string_literal: true

require 'csv'

file = Rails.root.join('db', 'seeds', 'unlink_reasons.csv')
csv = File.open(file, 'r:ISO-8859-1')
data = CSV.parse(csv, headers: true)

data.each do |row|
  UnlinkReason.find_or_create_by!(
    row.to_h.symbolize_keys
  )
end
