class UserSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_string, :string
  attribute :recent_sign_ins, :boolean
  attribute :old_sign_ins, :boolean
  attribute :caseworker_role, :boolean
  attribute :admin_role, :boolean
  attribute :data_analyst_role, :boolean

  def filters_applied?
    search_string.present? || recent_sign_ins || old_sign_ins || manager_role || caseworker_role || admin_role || data_analyst_role
  end

  def toggle_class
    filters_applied? ? 'moj-js-hidden' : ''
  end

  def form_class
    filters_applied? ? '' : 'moj-js-hidden'
  end

  def recent_count
    User.where(last_sign_in_at: 3.months.ago..).count
  end

  def old_count
    User.where('last_sign_in_at IS NULL OR last_sign_in_at < ?', 3.months.ago).count
  end

  def manager_count
    User.where('roles IS NULL OR ? = ANY(roles)', 'manager').count
  end

  def caseworker_count
    User.where('roles IS NULL OR ? = ANY(roles)', 'caseworker').count
  end
  def admin_count
    User.where('roles IS NULL OR ? = ANY(roles)', 'admin').count
  end

  def data_analyst_count
    User.where('? = ANY(roles)', 'data_analyst').count
  end
end
