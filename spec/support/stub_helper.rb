# frozen_string_literal: true

def api_url
  "#{CourtDataAdaptor.configuration.api_url}v1"
end

def api_url_v2
  "#{CourtDataAdaptor.configuration.api_url}v2"
end

def load_json_stub(relative_path)
  path = Rails.root.join('spec', 'fixtures', 'stubs', relative_path)
  File.read(path)
end
