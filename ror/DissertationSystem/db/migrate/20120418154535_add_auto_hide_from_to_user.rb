class AddAutoHideFromToUser < ActiveRecord::Migration
  def change
    add_column :users, :auto_hide_from, :integer, :default => User::AUTO_HIDE_FROM[:public]
  end
end
