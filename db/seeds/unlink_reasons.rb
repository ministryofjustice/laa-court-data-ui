# frozen_string_literal: true

require "csv"

file = Rails.root.join("db/seeds/unlink_reasons.csv")
data = File.open(file, "r:ISO-8859-1") do |csv|
  CSV.parse(csv, headers: true)
end

Rails.logger.info "Updating Unlink Description ..."
data.each do |row|
  Rails.logger.info { "Code: #{row['code']}, Description: #{row['description']}" }
  UnlinkReason.find_or_initialize_by(code: row["code"]).update!(description: row["description"])
end

Rails.logger.info "\nUnlink reason descriptions updated ^_^"
