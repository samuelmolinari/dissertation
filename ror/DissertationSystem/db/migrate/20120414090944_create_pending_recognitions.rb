class CreatePendingRecognitions < ActiveRecord::Migration
  def change
    create_table :pending_recognitions do |t|
      t.integer :face_id
      t.integer :user_id
      t.decimal :error_margin, :precision => 8, :scale => 3

      t.timestamps
    end
  end
end
