class ChangeUsernameNullOnUsers < ActiveRecord::Migration[6.0]
  def unique_username(user)
    i = 1
    base_username = "#{user.last_name.delete('\'')[0, 4]}-#{user.first_name.delete('\'')[0, 1]}".downcase
    username = base_username
    while User.find_by(username: username)
     username = "#{base_username}#{i}"
     i += 1
    end
    username
  end

  def up
    User.where(username: nil).each do |usr|
      usr.update(username: unique_username(usr))
    end

    change_column_null :users, :username, false
  end

  def down
    change_column_null :users, :username, true
  end
end
