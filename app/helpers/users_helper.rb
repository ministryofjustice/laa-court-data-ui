# frozen_string_literal: true

module UsersHelper
  def feature_flag_options
    User.feature_flags.keys.map do |key|
      [key, I18n.t("users.form.fields.feature_flags_options.#{key}", default: key.humanize)]
    end
  end

  def feature_flag_descriptions_for_user(user)
    return 'None' if user.feature_flags.empty?

    user.feature_flags.map do |flag|
      I18n.t("users.form.fields.feature_flags_options.#{flag}", default: flag.humanize)
    end.join(' | ')
  end
end
