class CreateFaces < ActiveRecord::Migration
  def change
    create_table :faces do |t|
      t.integer :photo_id
      t.integer :user_id
      t.integer :width
      t.integer :height
      t.integer :x
      t.integer :y
      t.integer :cover_type
      
      t.timestamps
    end
  end
end
