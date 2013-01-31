require 'spec_helper'

describe Profile do
  it { should belong_to(:institution) }
  it { should have_many(:arrangements) }
  it { should have_many(:focal_points) }
end
