require 'spec_helper'

describe Overflow do
  it "singleton_method_added" do
    expect(Overflow).to be_include(Comparable)
  end

  it "clone" do
    over = Overflow.new "c", 1
    expect(over.clone).to be_a_kind_of(Overflow)
  end

  it "i" do
    over = Overflow.new "c", 1
    expect(over.i).to be_a_kind_of(Complex)
    p over.i
  end
end


