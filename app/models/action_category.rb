class ActionCategory < ActiveRecord::Base
  belongs_to :arrangement

  def name
    super.humanize
  end

  def to_s
    description ? "#{name}: #{description}" : name
  end
end
