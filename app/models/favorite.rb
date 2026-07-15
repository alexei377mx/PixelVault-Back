class Favorite < ApplicationRecord
  belongs_to :user
  validates :game_id, presence: true
  validates :game_id, uniqueness: { scope: :user_id }
end
