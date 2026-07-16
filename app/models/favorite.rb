class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  validates :game_id, presence: true, uniqueness: { scope: :user_id }
end
