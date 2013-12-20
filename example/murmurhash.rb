#! /usr/bin/env ruby

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'overflow'

def murmur_hash str
  data = str.dup.unpack("C*")
  m = 0x5bd1e995
  r = 16
  length = Overflow.new "I", str.bytesize
  h = length * m

  while 4 <= length
    d = data.shift(4).pack("C*").unpack("I")[0]
    h += d
    h *= m
    h ^= h >> r
    length -= 4
  end

  if 2 < length
    h += data[2] << 16
  end
  if 1 < length
    h += data[1] << 8
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

  h.to_i
end

p murmur_hash "murmur" #=> 2800467524
