require 'spec_helper'

describe Overflow do
  it "class" do
    expect(Overflow).to be_include(Comparable)
    expect(Overflow.superclass).to eq(Numeric)
  end

  it "clone" do
    over = Overflow.new "c", 1
    expect(over.clone).to be_a_kind_of(Overflow)
  end

  it "coerce" do
    over = Overflow.new "c", 1
    c = Overflow.new "c", 2
    expect(over.coerce(2)).to eq([2,1])
    expect(over.coerce(c)).to eq([2,1])
    expect(2 + over).to eq(3)
    expect(2.1 + over).to eq(3.1)
  end

  it "i" do
    over = Overflow.new "c", 1
    expect(over.i).to be_a_kind_of(Complex)
  end

  it "<=>" do
    over = Overflow.new "Q", 1
    expect(over <=> 1).to eq(0)
    expect(over <=> 0xffffffffffffffff).to eq(-1)

    over.set 0xffffffffffffffff
    expect(over <=> 1).to eq(1)
    expect(over <=> 0xffffffffffffffff).to eq(0)
  end

  it "+@" do
    over = Overflow.new "c", 1
    expect((+over).to_i).to eq(1)
  end

  it "-@" do
    over = Overflow.new "c", 1
    expect((-over).to_i).to eq(-1)
  end

  it "hash" do
    a = Overflow.new "i", 10
    b = Overflow.new "i", 10
    c = Overflow.new "Q", 10
    d = Overflow.new "i", 100
    expect(a.hash == b.hash).to be true
    expect(a.hash == c.hash).to be false
    expect(a.hash == d.hash).to be false
  end

  it "eql?" do
    a = Overflow.new "i", 10
    b = Overflow.new "i", 10
    c = Overflow.new "Q", 10
    d = Overflow.new "i", 100
    fix = 10
    expect(a.eql?(fix)).to be false
    expect(a.eql?(b)).to be true
    expect(a.eql?(c)).to be false
    expect(a.eql?(d)).to be false
    expect(fix.eql?(a)).to be false
  end
end


