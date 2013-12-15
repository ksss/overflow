require 'spec_helper'

describe Overflow do
  it "gc safe" do
    over = Overflow.new "c"
    GC.start
    over.set 1
    GC.start
    expect(over.to_i).to eq(1)
  end
end
