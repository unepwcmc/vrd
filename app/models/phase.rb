class Phase < ActiveRecord::Base
  belongs_to :arrangement
  
  def to_s
    case name
    when 'ONE'
      'I'
    when 'TWO'
      'II'
    else
      'III'
    end
  end
end
