class CreateSongs < ActiveRecord::Migration[6.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :author
      t.integer :category
      t.integer :number

      t.timestamps
    end
  end
end
