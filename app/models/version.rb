class Version < ApplicationRecord
  validates :title, presence: true
  belongs_to :song
  belongs_to :user
end
