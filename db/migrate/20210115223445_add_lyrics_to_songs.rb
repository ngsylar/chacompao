class AddLyricsToSongs < ActiveRecord::Migration[6.0]
  def change
    add_column :songs, :lyrics, :text
  end
end
