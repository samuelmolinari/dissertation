class CreateAutoHideWhenWithUsers < ActiveRecord::Migration
  def change
    create_table :auto_hide_when_with_users do |t|
      t.integer :auto_hide_from_user_id
      t.integer :user_id

      t.timestamps
    end
  end
end
