require 'spec_helper'

describe Overflow do
  CHAR_MAX   = 0x7f
  CHAR_MIN   = -0x80
  UCHAR_MAX  = 0xff

  SHRT_MAX   = 0x7fff
  SHRT_MIN   = -0x8000
  USHRT_MAX  = 0xffff

  INT_MAX    = 0x7fffffff
  INT_MIN    = -0x80000000
  UINT_MAX   = 0xffffffff

  LLONG_MAX  = 0x7fffffffffffffff
  LLONG_MIN  = -0x8000000000000000
  ULLONG_MAX = 0xffffffffffffffff

  it "initialize" do
    %w{c C s S i I l L q Q}.each do |i|
      Overflow.new i
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
    over = Overflow.new "c"
    over.set(1)
    expect(over << 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(1)
  end

  it "<< 8bit" do
    over = Overflow.new "c"
    over.set(CHAR_MAX)
    over = over << 7
    expect(over.to_i).to eq(CHAR_MIN)

    over = Overflow.new "C"
    over.set(UCHAR_MAX)
    over = over << 7
    expect(over.to_i).to eq(CHAR_MAX + 1)
  end

  it "<< 16bit" do
    over = Overflow.new "s"
    over.set(SHRT_MAX)
    over = over << 15
    expect(over.to_i).to eq(SHRT_MIN)

    over = Overflow.new "S"
    over.set(USHRT_MAX)
    over = over << 15
    expect(over.to_i).to eq(SHRT_MAX + 1)
  end

  it "<< 32bit" do
    over = Overflow.new "i"
    over.set(INT_MAX)
    over = over << 31
    expect(over.to_i).to eq(INT_MIN)

    over = Overflow.new "I"
    over.set(UINT_MAX)
    over = over << 31
    expect(over.to_i).to eq(INT_MAX + 1)
  end

  it "<< 64bit" do
    over = Overflow.new "q"
    over.set(LLONG_MAX)
    over = over << 63
    expect(over.to_i).to eq(LLONG_MIN)

    over = Overflow.new "Q"
    over.set(ULLONG_MAX)
    over = over << 63
    expect(over.to_i).to eq(LLONG_MAX + 1)
  end

  it ">>" do
    over = Overflow.new "c"
    over.set(1)
    expect(over >> 1).to be_a_kind_of(Overflow)
    expect(over.to_i).to eq(1)
  end

  it ">> 8bit" do
    over = Overflow.new "c"
    over.set(CHAR_MAX)
    over = over >> 7
    expect(over.to_i).to eq(0)

    over = Overflow.new "C"
    over.set(UCHAR_MAX)
    over = over >> 7
    expect(over.to_i).to eq(1)
  end

  it ">> 16bit" do
    over = Overflow.new "s"
    over.set(SHRT_MAX)
    over = over >> 15
    expect(over.to_i).to eq(0)

    over = Overflow.new "S"
    over.set(USHRT_MAX)
    over = over >> 15
    expect(over.to_i).to eq(1)
  end

  it ">> 32bit" do
    over = Overflow.new "i"
    over.set(INT_MAX)
    over = over >> 31
    expect(over.to_i).to eq(0)

    over = Overflow.new "I"
    over.set(UINT_MAX)
    over = over >> 31
    expect(over.to_i).to eq(1)
  end

  it ">> 64bit" do
    over = Overflow.new "q"
    over.set(LLONG_MAX)
    over = over >> 63
    expect(over.to_i).to eq(0)

    over = Overflow.new "Q"
    over.set(ULLONG_MAX)
    over = over >> 63
    expect(over.to_i).to eq(1)
  end

  it "+ 8bit" do
    over = Overflow.new "c"
    over.set(CHAR_MAX)
    over += 1
    expect(over.to_i).to eq(CHAR_MIN)

    over = Overflow.new "C"
    over.set(UCHAR_MAX)
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 16bit" do
    over = Overflow.new "s"
    over.set(SHRT_MAX)
    over += 1
    expect(over.to_i).to eq(SHRT_MIN)

    over = Overflow.new "S"
    over.set(USHRT_MAX)
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 32bit" do
    over = Overflow.new "l"
    over.set(INT_MAX)
    over += 1
    expect(over.to_i).to eq(INT_MIN)

    over = Overflow.new "L"
    over.set(UINT_MAX)
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "+ 64bit" do
    over = Overflow.new "q"
    over.set(LLONG_MAX)
    over += 1
    expect(over.to_i).to eq(LLONG_MIN)

    over = Overflow.new "Q"
    over.set(ULLONG_MAX)
    over += 1
    expect(over.to_i).to eq(0)
  end

  it "- 8bit" do
    over = Overflow.new "c"
    over.set(CHAR_MIN)
    over -= 1
    expect(over.to_i).to eq(CHAR_MAX)

    over = Overflow.new "C"
    over.set(0)
    over -= 1
    expect(over.to_i).to eq(UCHAR_MAX)
  end

  it "- 16bit" do
    over = Overflow.new "s"
    over.set(SHRT_MIN)
    over -= 1
    expect(over.to_i).to eq(SHRT_MAX)

    over = Overflow.new "S"
    over.set(0)
    over -= 1
    expect(over.to_i).to eq(USHRT_MAX)
  end

  it "- 32bit" do
    over = Overflow.new "l"
    over.set(INT_MIN)
    over -= 1
    expect(over.to_i).to eq(INT_MAX)

    over = Overflow.new "L"
    over.set(0)
    over -= 1
    expect(over.to_i).to eq(UINT_MAX)
  end

  it "- 64bit" do
    over = Overflow.new "q"
    over.set(LLONG_MIN)
    over -= 1
    expect(over.to_i).to eq(LLONG_MAX)

    over = Overflow.new "Q"
    over.set(0)
    over -= 1
    expect(over.to_i).to eq(ULLONG_MAX)
  end

  it "* 8bit" do
    over = Overflow.new "c"
    over.set(CHAR_MAX)
    over *= CHAR_MAX
    expect(over.to_i).to eq(1)

    over.set(CHAR_MIN)
    over *= CHAR_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "C"
    over.set(UCHAR_MAX)
    over *= UCHAR_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 16bit" do
    over = Overflow.new "s"
    over.set(SHRT_MAX)
    over *= SHRT_MAX
    expect(over.to_i).to eq(1)

    over.set(SHRT_MIN)
    over *= SHRT_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "S"
    over.set(USHRT_MAX)
    over *= USHRT_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 32bit" do
    over = Overflow.new "l"
    over.set(INT_MAX)
    over *= INT_MAX
    expect(over.to_i).to eq(1)

    over.set(INT_MIN)
    over *= INT_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "L"
    over.set(UINT_MAX)
    over *= UINT_MAX
    expect(over.to_i).to eq(1)
  end

  it "* 64bit" do
    over = Overflow.new "q"
    over.set(LLONG_MAX)
    over *= LLONG_MAX
    expect(over.to_i).to eq(1)

    over.set(LLONG_MIN)
    over *= LLONG_MIN
    expect(over.to_i).to eq(0)

    over = Overflow.new "Q"
    over.set(ULLONG_MAX)
    over *= ULLONG_MAX
    expect(over.to_i).to eq(1)
  end

end



