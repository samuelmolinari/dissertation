class RemoveWhenWithUserIdFromAutoHideFromUser < ActiveRecord::Migration
  def up
    remove_column :auto_hide_from_users, :when_with_user_id
      end

  def down
    add_column :auto_hide_from_users, :when_with_user_id, :integer
  end
end
