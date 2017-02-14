#!/usr/bin/env ruby

require 'json'

data = JSON.parse(ARGF.read)

data.keys.sort.each do |location|
  data[location].sort!
  data[location].map! do |url|
    type = case url
    when /\.css$/ then 'style'
    when /\.js$/ then 'script'
    when /\.html$/ then 'document'
    else nil
    end
    type = ";as=#{type}" if type
    %|<#{url}>;rel=preload#{type}|
  end
end

puts JSON.dump(data)
