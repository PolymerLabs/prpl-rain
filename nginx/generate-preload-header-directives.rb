#!/usr/bin/env ruby

# Given a JSON file (arg or stdin) of urls and the link
# headers for each, construct the header directives to
# include in a location in nginx config.

require 'json'

data = JSON.parse(ARGF.read)

data.keys.sort.each do |url|
  regexp_url = url.gsub(/\./, '\\.').gsub(/\*+/,'.*')
  puts "if ($request_uri ~ ^#{regexp_url}$) {"
  data[url].each do |header|
    puts "add_header Link \"#{header}\";"
  end
  puts "}"
end
