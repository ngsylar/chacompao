class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :song
  belongs_to :version
  validates :song, uniqueness: { scope: :user }
  
  scope :sorted_by_song_title, -> { 
    joins(:song).merge(
      Song.order("LOWER(title)")
    )
  }
end
