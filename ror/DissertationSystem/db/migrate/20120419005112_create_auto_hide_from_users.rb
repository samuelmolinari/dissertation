class CreateAutoHideFromUsers < ActiveRecord::Migration
  def change
    create_table :auto_hide_from_users do |t|
      t.integer :user_id
      t.integer :hide_from_user_id
      t.integer :when_with_user_id
      t.integer :cover_type

      t.timestamps
    end
  end
end
