begin
  require "overflow/#{RUBY_VERSION[/\d+.\d+/]}/overflow"
rescue LoadError
  require "overflow/overflow"
end
