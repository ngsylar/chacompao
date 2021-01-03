class CreateSongs < ActiveRecord::Migration[6.0]
  def change
    create_table :songs do |t|
      t.text :title
      t.text :author
      t.text :category
      t.integer :number

      t.timestamps
    end
  end
end
