class Brand < ApplicationRecord
  has_one_attached :logo
  has_many :statics
  has_many :youtubes
  has_many :reviews
  has_many :tv_spots
end
