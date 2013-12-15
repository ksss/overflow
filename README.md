# Overflow

Overflow is a class to overflow calculated as C language in Ruby.

## Usage

```ruby
def murmur_hash str
  data = str.dup.unpack("C*")
  m = 0x5bd1e995
  r = 16
  length = Overflow.new "C"
  length.set str.bytesize
  h = length * m

  while 4 <= length
    d = data.shift(4).pack("C*").unpack("I")[0]
    h += d
    h *= m
    h ^= h >> r
    length -= 4
  end

  if 2 < length
    h += (data[2] << 16) & 0xffffffff
  end
  if 1 < length
    h += (data[1] << 8) & 0xffffffff
  end
  if 0 < length
    h += data[0]
    h *= m
    h ^= h >> r
  end

  h *= m
  h ^= h >> 10
  h *= m
  h ^= h >> 17

  h
end
```

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
