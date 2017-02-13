#!/usr/bin/env ruby

# Basic PRPL server configuration generator for nginx

require 'erb'

server_name = ARGV[0]
document_root = ARGV[1] || "/var/www/#{server_name}"

puts ERB.new(DATA.read).result

__END__

server {
  listen       80;
  server_name  <%= server_name %>;
  return       301  https://<%= server_name %>;
}

server {
  listen        8080;
  server_name   <%= server_name %>;
  root          <%= document_root %>;
  gzip          on;
  gzip_proxied  any;

  # Don't allow reading of dot-prefixed files
  location ~ ^\.|/\. {
    return 302 https://<%= server_name %>;
  }

  # Include any directives for server level
  include <%= document_root %>/.nginx/server-includes/*;

  # For paths that don't represent files (no dots), PRPL app will return
  # the standard index.html file.
  location ~ ^([^.]+)$ {

    # Include special path handling prior to index.html rewrite.
    include <%= document_root%>/.nginx/path-includes/*;

    rewrite (.*) /index.html last;
  }

  # Include extra nginx configs in document root
  location / {

    # Include includes for the main location.  Mostly these will
    # be header directives for preload links.
    include <%= document_root %>/.nginx/location-includes/*;
  }
}
