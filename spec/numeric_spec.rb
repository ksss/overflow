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

    ary = []
    hash = {}
    100.times { ary << c *= 3 }
    ary.each_with_index {|x, i| hash[x] = i}
    ary.each_with_index do |x, i|
      expect(hash[x]).to eq(i)
    end
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

  it "to_f" do
    a = Overflow.new "c", 10
    expect(a.to_f).to eq(10.0)
  end

  it "fdiv" do
    a = Overflow.new "c", 10
    expect(a.fdiv(2)).to eq(5.0)
  end

  it "div" do
    a = Overflow.new "c", 10
    expect(a.div(3)).to eq(3)
  end

  it "divmod" do
    a = Overflow.new "c", 10
    expect(a.divmod(3)).to eq([3, 1])
  end

  it "modulo" do
    a = Overflow.new "c", 10
    expect(a.modulo(3)).to eq(1)
    expect(a % 3).to eq(1)
  end

  it "remainder" do
    a = Overflow.new "c", 13
    expect(a.remainder(4)).to eq(1)
    expect(a.remainder(4.25)).to eq(0.25)
  end

  it "abs" do
    a = Overflow.new "c", -10
    b = Overflow.new "c", 10
    expect(a.abs).to eq(10)
    expect(a.magnitude).to eq(10)
    expect(b.abs).to eq(10)
  end

  it "to_int" do
    a = Overflow.new "c", 10
    expect(a.to_int).to eq(10)
  end

  it "real?" do
    a = Overflow.new "c", 10
    expect(a.real?).to be true
  end

  it "integer?" do
    a = Overflow.new "c", 10
    expect(a.integer?).to be true
  end

  it "zero?" do
    a = Overflow.new "c", 0
    b = Overflow.new "c", 10
    expect(a.zero?).to be true
    expect(b.zero?).to be false
  end

  it "nonzero?" do
    a = Overflow.new "c", 0
    b = Overflow.new "c", 10
    expect(a.nonzero?).to be nil
    expect(b.nonzero?).to eq(b)
  end

  it "floor" do
    a = Overflow.new "c", 10
    expect(a.floor).to eq(10)
  end

  it "ceil" do
    a = Overflow.new "c", 10
    expect(a.ceil).to eq(10)
  end

  it "round" do
    a = Overflow.new "c", 10
    expect(a.round).to eq(10)
  end

  it "truncate" do
    a = Overflow.new "c", 10
    expect(a.truncate).to eq(10)
  end
end
