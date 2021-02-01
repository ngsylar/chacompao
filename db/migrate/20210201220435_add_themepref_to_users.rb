class AddThemeprefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :themepref, :integer
  end
end
