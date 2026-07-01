# frozen_string_literal: true

require 'csv'

file = Rails.root.join('db', 'seeds', 'unlink_reasons.csv')
data = File.open(file, 'r:ISO-8859-1') do |csv|
  CSV.parse(csv, headers: true)
end

data.each do |row|
  attrs = row.to_h.symbolize_keys
  UnlinkReason.find_or_initialize_by(code: attrs[:code]).update!(attrs)
end
