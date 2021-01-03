class CreateVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :versions do |t|
      t.belongs_to :song, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.text :title
      t.text :key
      t.text :songstruct
      t.text :songparts
      t.text :partsstructs

      t.timestamps
    end
  end
end
