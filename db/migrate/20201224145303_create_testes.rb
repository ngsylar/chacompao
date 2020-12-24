class CreateTestes < ActiveRecord::Migration[6.0]
  def change
    create_table :testes do |t|
      t.string :nome
      t.text :texto

      t.timestamps
    end
  end
end
