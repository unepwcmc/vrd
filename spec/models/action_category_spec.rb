require 'spec_helper'

describe ActionCategory do
  it { should belong_to(:arrangement) }
end
