class CreateUserConnections < ActiveRecord::Migration
  def change
    create_table :user_connections do |t|
      t.integer :user_id
      t.integer :connected_to_user_id

      t.timestamps
    end
  end
end
