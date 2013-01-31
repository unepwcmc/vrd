class Region < ActiveRecord::Base
  has_many :institutions
  
  def to_s
    name
  end
end
