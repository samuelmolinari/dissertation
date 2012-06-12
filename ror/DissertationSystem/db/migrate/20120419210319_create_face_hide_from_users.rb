class CreateFaceHideFromUsers < ActiveRecord::Migration
  def change
    create_table :face_hide_from_users do |t|
      t.integer :face_id
      t.integer :hide_from_user_id
      t.integer :cover_type

      t.timestamps
    end
  end
end
