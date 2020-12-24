class CreateSongs < ActiveRecord::Migration[6.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :author
      t.string :category
      t.integer :number

      t.timestamps
    end
  end
end
