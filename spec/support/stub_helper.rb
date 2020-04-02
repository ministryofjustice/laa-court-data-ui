# frozen_string_literal: true

def load_json_stub(relative_path)
  path = Rails.root.join('spec', 'fixtures', 'stubs', relative_path)
  File.read(path)
end
