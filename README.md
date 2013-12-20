# Overflow

[![Gem Version](https://badge.fury.io/rb/overflow.png)](http://badge.fury.io/rb/overflow)
[![Build Status](https://travis-ci.org/ksss/overflow.png?branch=master)](https://travis-ci.org/ksss/overflow)

Overflow is a class to overflow calculated as C language in Ruby.

## Usage

```ruby
require 'overflow'

over = Overflow.new "C" #=> "C" mean 8bit unsigned char (same as pack template)
over.set 255 #=> set a number (0b11111111)
p over.to_i #=> 255 (out Fixnum object)
over = over << 4 #=> left bit shift (0b11110000)
p over.to_i #=> 240 (overflow bit is dropped)
p (over >> 4).to_i #=> 15 (0b00001111)
p (200 - over) #=> -40 (Call Overflow#coerce.)
```

## APIs

### initialize(type[, number])

**type**: defined C type

- c: `int8_t`
- C: `uint8_t`
- s: `int16_t`
- S: `uint16_t`
- i: `int32_t`
- I: `uint32_t`
- l: `int32_t` same at "i"
- L: `uint32_t` same at "I"
- q: `int64_t`
- Q: `uint64_t`

### set(number)

```ruby
over = Overflow.new "C"
over.set 1
p over.to_i #=> 1
over.set 10
p over.to_i #=> 10
```

### to\_i

```ruby
over = Overflow.new "C", 256
over.to_i #=> 0
```

### +, -, \*

```ruby
over = Overflow.new "C", 100
over += 200 #=> 44
over -= 50  #=> 250
over *= 10  #=> 196
```

###  ~, &, |, ^

```ruby
over = Overflow.new "C", 0xaa
~over #=> 0x55
over & 0x99 #=> 0x88
over | 0x99 #=> 0xbb
over ^ 0x99 #=> 0x33
```

### \<\<, \>\>

```ruby
over = Overflow.new "C", 0xff
over << 4 #=> 0xf0
over >> 4 #=> 0x0f
```

and all `Numeric` methods.

## Class tree

Overflow < Numeric

## Installation

Add this line to your application's Gemfile:

    gem 'overflow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install overflow

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See the file LICENSE.txt
