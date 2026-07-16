class AddUniqueIndexToFavorites < ActiveRecord::Migration[8.1]
  def change
    add_index :favorites, [ :user_id, :game_id ], unique: true
    add_reference :favorites, :category, foreign_key: true, null: true
  end
end
