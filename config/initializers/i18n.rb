# frozen_string_literal: true

# Note that appending directly to I18n.load_paths instead of to
# the application's configured i18n will not override translations
# from external gems.
# see https://guides.rubyonrails.org/i18n.html#configure-the-i18n-module

I18n.load_path = I18n.load_path +
                 Rails.root.glob('config/locales/**/*.{rb,yml}')
