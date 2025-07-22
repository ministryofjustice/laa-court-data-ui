# frozen_string_literal: true

def api_url
  Cda.configuration.api_url
end

def load_json_stub(relative_path)
  path = Rails.root.join('spec', 'fixtures', 'stubs', relative_path)
  File.read(path)
end
