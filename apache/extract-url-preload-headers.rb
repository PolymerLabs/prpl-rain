#!/usr/bin/env ruby

require 'json'

preload = {}
input = ARGF.readlines

input_state = :out_location_block
location = nil

input.each do |line|
  case input_state
  when :out_location_block
    case line
    when /<LocationMatch "?([^">]*)"?>/
      location = $1.gsub(/\[\^\.\]\*/, '__NOTDOT__').gsub(/\^|\$/,'').gsub(/\.\*?\+?/,'*')
      input_state = :in_location_block
    when /<Location "?([^">]*)"?>/
      location = $1
      input_state = :in_location_block
    end
  when :in_location_block
    case line
    when /<\/Location/
      input_state = :out_location_block
    when /<([^>]+)>.*\brel=preload\b/
      (preload[location] ||= []) << $1
    end
  end
end

puts JSON.dump(preload)
