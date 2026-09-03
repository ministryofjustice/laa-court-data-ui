# frozen_string_literal: true

module UsersHelper
  def feature_flag_options
    User.feature_flags.keys.map do |key|
      [key, I18n.t("users.form.fields.feature_flags_options.#{key}", default: key.humanize)]
    end
  end

  def feature_flag_descriptions_for_user(user)
    return "None" if user.feature_flags.empty?

    user.feature_flags.map { |flag|
      I18n.t("users.form.fields.feature_flags_options.#{flag}", default: flag.humanize)
    }.join(" | ")
  end

  def user_sorter_header(column)
    sorter_header(
      path: users_path,
      column: column,
      direction_key: :user_sort_direction,
      column_key: :user_sort_column,
      label: t("users.generic.#{column}"),
      default_sort_column: "name",
    )
  end
end
