# frozen_string_literal: true

require 'csv'

file = Rails.root.join('db', 'seeds', 'unlink_reasons.csv')
data = File.open(file, 'r:ISO-8859-1') do |csv|
  CSV.parse(csv, headers: true)
end

data.each do |row|
  UnlinkReason.find_or_create_by!(
    row.to_h.symbolize_keys
  )
end
