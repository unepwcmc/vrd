class Profile < ActiveRecord::Base
  belongs_to :institution
  has_many :arrangements
  has_many :focal_points
end
