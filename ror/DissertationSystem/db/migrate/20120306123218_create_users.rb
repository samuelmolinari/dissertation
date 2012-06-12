class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :uname
      t.string :email
      t.date :dob
      t.string :hashed_password
      t.string :salt_password

      t.timestamps
    end
  end
end
