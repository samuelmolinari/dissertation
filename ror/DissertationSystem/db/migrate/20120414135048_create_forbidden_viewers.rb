class CreateForbiddenViewers < ActiveRecord::Migration
  def change
    create_table :forbidden_viewers do |t|
      t.integer :user_id
      t.integer :forbidden_viewer_id

      t.timestamps
    end
  end
end
