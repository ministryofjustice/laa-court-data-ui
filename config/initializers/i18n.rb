# frozen_string_literal: true

I18n.load_path = I18n.load_path +
                 Dir[File.expand_path('config/locales') + '/**/*.yml']
