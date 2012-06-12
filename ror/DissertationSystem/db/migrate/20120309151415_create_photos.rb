class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :ref
      t.string :name
      t.string :description
      t.integer :user_id
      t.integer :album_id
      t.integer :detection_width
      t.integer :detection_height

      t.timestamps
    end
  end
end
