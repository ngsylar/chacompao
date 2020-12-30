class Song < ApplicationRecord
    validates :title, presence: true
    has_many :versions, dependent: :destroy
end
