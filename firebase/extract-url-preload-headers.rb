#!/usr/bin/env ruby

# Read JSON data from a firebase.json file (arg or stdin)
# and output a JSON file of urls and the paths to preload.

require 'json'

data = JSON.parse(ARGF.read)

preload = {}

data['hosting']['headers'].each do |header|
  source = header['source']
  link = header['headers'].find { |h| h['key'] == 'Link' }
  continue unless link
  links = link['value'].split(',')
  links_for_url = preload[source] ||= []
  links.each { |l| links_for_url << l.match(/<([^>]+)>/)[1] }
end

puts JSON.dump(preload)
