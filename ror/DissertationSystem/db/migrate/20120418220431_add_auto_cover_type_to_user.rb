class AddAutoCoverTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :auto_cover_type, :integer
  end
end
