require 'spec_helper'

describe Overflow do
  it "initialize" do
    %w{c C s S i I l L q Q}.each do |i|
      expect(Overflow.new i).to be_a_kind_of(Overflow)
      expect(Overflow.new i, 1).to be_a_kind_of(Overflow)
    end
  end

  it "set and to_i type 'c'" do
    over = Overflow.new "c"
    expect(over.set(0).to_i).to eq(0)
    expect(over.set(CHAR_MAX).to_i).to eq(CHAR_MAX)
    expect(over.set(CHAR_MAX + 1).to_i).to eq(CHAR_MIN)
    expect(over.set(UCHAR_MAX).to_i).to eq(-1)
    expect(over.set(UCHAR_MAX + 1).to_i).to eq(0)
    expect(over.set(UCHAR_MAX + 2).to_i).to eq(1)
  end

  it "set and to_i type 's'" do
    over = Overflow.new "s"
    expect(over.set(SHRT_MAX).to_i).to eq(SHRT_MAX)
    expect(over.set(SHRT_MAX + 1).to_i).to eq(SHRT_MIN)
    expect(over.set(USHRT_MAX).to_i).to eq(-1)
    expect(over.set(USHRT_MAX + 1).to_i).to eq(0)
    expect(over.set(USHRT_MAX + 2).to_i).to eq(1)
  end

  it "set and to_i type 'i'" do
    over = Overflow.new "i"
    expect(over.set(INT_MAX).to_i).to eq(INT_MAX)
    expect(over.set(INT_MAX + 1).to_i).to eq(INT_MIN)
    expect(over.set(UINT_MAX).to_i).to eq(-1)
    expect(over.set(UINT_MAX + 1).to_i).to eq(0)
    expect(over.set(UINT_MAX + 2).to_i).to eq(1)
  end

  it "set and to_i type 'q'" do
    over = Overflow.new "q"
    expect(over.set(LLONG_MAX).to_i).to eq(LLONG_MAX)
    expect(over.set(LLONG_MAX + 1).to_i).to eq(LLONG_MIN)
    expect(over.set(ULLONG_MAX).to_i).to eq(-1)
    expect(over.set(ULLONG_MAX + 1).to_i).to eq(0)
    expect(over.set(ULLONG_MAX + 2).to_i).to eq(1)
  end

  it "<<" do
    over = Overflow.new "c", 1
    expect(over << 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(1)
  end

  it "<< 8bit" do
    over = Overflow.new "c", CHAR_MAX
    over = over << 7
    expect(over.to_i).to eq(CHAR_MIN)

    over = Overflow.new "C", UCHAR_MAX
    over = over << 7
    expect(over.to_i).to eq(CHAR_MAX + 1)
  end

  it "<< 16bit" do
    over = Overflow.new "s", SHRT_MAX
    over = over << 15
    expect(over.to_i).to eq(SHRT_MIN)

    over = Overflow.new "S", USHRT_MAX
    over = over << 15
    expect(over.to_i).to eq(SHRT_MAX + 1)
  end

  it "<< 32bit" do
    over = Overflow.new "i", INT_MAX
    over = over << 31
    expect(over.to_i).to eq(INT_MIN)

    over = Overflow.new "I", UINT_MAX
    over = over << 31
    expect(over.to_i).to eq(INT_MAX + 1)
  end

  it "<< 64bit" do
    over = Overflow.new "q", LLONG_MAX
    over = over << 63
    expect(over.to_i).to eq(LLONG_MIN)

    over = Overflow.new "Q", ULLONG_MAX
    over = over << 63
    expect(over.to_i).to eq(LLONG_MAX + 1)
  end

  it ">>" do
    over = Overflow.new "c", 1
    expect(over >> 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(1)
  end

  it ">> 8bit" do
    over = Overflow.new "c", CHAR_MAX
    over = over >> 7
    expect(over.to_i).to eq(0)

    over = Overflow.new "C", UCHAR_MAX
    over = over >> 7
    expect(over.to_i).to eq(1)
  end

  it ">> 16bit" do
    over = Overflow.new "s", SHRT_MAX
    over = over >> 15
    expect(over.to_i).to eq(0)

    over = Overflow.new "S", USHRT_MAX
    over = over >> 15
    expect(over.to_i).to eq(1)
  end

  it ">> 32bit" do
    over = Overflow.new "i", INT_MAX
    over = over >> 31
    expect(over.to_i).to eq(0)

    over = Overflow.new "I", UINT_MAX
    over = over >> 31
    expect(over.to_i).to eq(1)
  end

  it ">> 64bit" do
    over = Overflow.new "q", LLONG_MAX
    over = over >> 63
    expect(over.to_i).to eq(0)

    over = Overflow.new "Q", ULLONG_MAX
    over = over >> 63
    expect(over.to_i).to eq(1)
  end

  it "+" do
    over = Overflow.new "c", 1
    clone = over.clone
    expect(over + 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(clone.to_i)
    expect((over + clone).to_i).to eq(2)
  end

  it "+ 8bit" do
    over = Overflow.new "c", CHAR_MAX
    over += 1
    expect(over.to_i).to eq(CHAR_MIN)

    over = Overflow.new "C", UCHAR_MAX
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 16bit" do
    over = Overflow.new "s", SHRT_MAX
    over += 1
    expect(over.to_i).to eq(SHRT_MIN)

    over = Overflow.new "S", USHRT_MAX
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 32bit" do
    over = Overflow.new "l", INT_MAX
    over += 1
    expect(over.to_i).to eq(INT_MIN)

    over = Overflow.new "L", UINT_MAX
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 64bit" do
    over = Overflow.new "q", LLONG_MAX
    over += 1
    expect(over.to_i).to eq(LLONG_MIN)

    over = Overflow.new "Q", ULLONG_MAX
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "-" do
    over = Overflow.new "c", 1
    clone = over.clone
    expect(over - 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(clone.to_i)
    expect((over - clone).to_i).to eq(0)
  end

  it "- 8bit" do
    over = Overflow.new "c", CHAR_MIN
    over -= 1
    expect(over.to_i).to eq(CHAR_MAX)

    over = Overflow.new "C", 0
    over -= 1
    expect(over.to_i).to eq(UCHAR_MAX)
  end

  it "- 16bit" do
    over = Overflow.new "s", SHRT_MIN
    over -= 1
    expect(over.to_i).to eq(SHRT_MAX)

    over = Overflow.new "S", 0
    over -= 1
    expect(over.to_i).to eq(USHRT_MAX)
  end

  it "- 32bit" do
    over = Overflow.new "l", INT_MIN
    over -= 1
    expect(over.to_i).to eq(INT_MAX)

    over = Overflow.new "L", 0
    over -= 1
    expect(over.to_i).to eq(UINT_MAX)
  end

  it "- 64bit" do
    over = Overflow.new "q", LLONG_MIN
    over -= 1
    expect(over.to_i).to eq(LLONG_MAX)

    over = Overflow.new "Q", 0
    over -= 1
    expect(over.to_i).to eq(ULLONG_MAX)
  end

  it "*" do
    over = Overflow.new "c", 1
    clone = over.clone
    expect(over * 2).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(clone.to_i)
    expect((over * clone).to_i).to eq(1)
  end

  it "* 8bit" do
    over = Overflow.new "c", CHAR_MAX
    over *= CHAR_MAX
    expect(over.to_i).to eq(1)

    over.set(CHAR_MIN)
    over *= CHAR_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "C", UCHAR_MAX
    over *= UCHAR_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 16bit" do
    over = Overflow.new "s", SHRT_MAX
    over *= SHRT_MAX
    expect(over.to_i).to eq(1)

    over.set(SHRT_MIN)
    over *= SHRT_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "S", USHRT_MAX
    over *= USHRT_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 32bit" do
    over = Overflow.new "l", INT_MAX
    over *= INT_MAX
    expect(over.to_i).to eq(1)

    over.set(INT_MIN)
    over *= INT_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "L", UINT_MAX
    over *= UINT_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 64bit" do
    over = Overflow.new "q", LLONG_MAX
    over *= LLONG_MAX
    expect(over.to_i).to eq(1)

    over.set(LLONG_MIN)
    over *= LLONG_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "Q", ULLONG_MAX
    over *= ULLONG_MAX
    expect(over.to_i).to eq(1)
  end

  it "~" do
    over = Overflow.new "C", 0xaa
    rev = ~over
    expect(over.to_i).to eq(0xaa)
    expect(rev.to_i).to eq(0x55)
  end

  it "&" do
    over = Overflow.new "C", 0xaa
    clone = over.clone
    a = over & 0x99
    expect(over.to_i).to eq(0xaa)
    expect(a.to_i).to eq(0x88)
    over &= 0xffffffffffffffffff
    expect(over.to_i).to eq(0xaa)
    expect((over & clone).to_i).to eq(0xaa)
  end

  it "|" do
    over = Overflow.new "C", 0xaa
    clone = over.clone
    a = over | 0x99
    expect(over.to_i).to eq(0xaa)
    expect(a.to_i).to eq(0xbb)
    over |= 0xffffffffffffffffff
    expect(over.to_i).to eq(0xff)
    expect((over | clone).to_i).to eq(0xff)
  end

  it "^" do
    over = Overflow.new "C", 0xaa
    clone = over.clone
    a = over ^ 0x99
    expect(over.to_i).to eq(0xaa)
    expect(a.to_i).to eq(0x33)
    over ^= 0xffffffffffffffffff
    expect(over.to_i).to eq(0x55)
    expect((over ^ clone).to_i).to eq(0xff)
  end
end
