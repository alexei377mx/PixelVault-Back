class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :game_id

      t.timestamps
    end
    add_index :favorites, :game_id
  end
end
