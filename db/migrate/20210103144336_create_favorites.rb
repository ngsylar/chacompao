class CreateFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :favorites do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.references :version, null: false, foreign_key: true

      t.timestamps
    end
  end
end
