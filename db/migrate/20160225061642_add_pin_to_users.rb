class AddPinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pin, :string
    add_column :users, :verified, :boolean
  end
end
