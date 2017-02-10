#!/usr/bin/env ruby


# TODO(usergenic): Port script to a unified builder with a couple of options.
# This file generates the link header directives from the LocationMatch
# directives in the conf files I found in our /etc/apache2/push-conf folder,
# generates server config for shop.polymer-project.org and then builds the
# news app and copies configs into an .nginx folder in the unbundled build
# output.  This makes that folder suitable to upload as is.

require 'erb'

host = ARGV[0]

script_dir = File.expand_path(File.dirname(__FILE__))
root_dir = File.expand_path(File.join(script_dir, '../..'))
repo_dir = File.join(script_dir, 'shop.git')
apache_confs = File.join(script_dir, 'apache-push-conf/*.conf')
document_root = '/var/www/shop.polymer-project.org'

system ERB.new(DATA.read).result

__END__

rm -rf <%= repo_dir %>/build
if [ ! -d "<%= repo_dir %>" ]; then
  git clone git@github.com:Polymer/shop.git <%= repo_dir %>
fi
if [ ! -d "<%= repo_dir %>" ]; then
  echo "problem cloning"
  exit 1
fi

mkdir -p <%= repo_dir %>
cd <%= repo_dir %>
bower install
polymer build

mkdir -p build/unbundled/.nginx/location-includes
mkdir -p build/unbundled/.nginx/path-includes

<%= root_dir %>/nginx/generate-server-config.rb shop.polymer-project.org > \
    build/unbundled/.nginx/shop.polymer-project.org.conf

cat <%= apache_confs %> \
    | <%= root_dir %>/apache/extract-url-preload-headers.rb \
    | <%= root_dir %>/core/preload-urls-to-link-header-values.rb \
    | <%= root_dir %>/nginx/generate-preload-header-directives.rb > \
    build/unbundled/.nginx/location-includes/link-headers.conf


echo "1. Copy the <%= repo_dir %>/build/unbundled folder to the server at <%= document_root %>"
echo "2. On server: sudo chown -R root <%= document_root %>"
echo "3. On server: sudo chgrp -R root <%= document_root %>"
echo "4. On server: sudo ln -s <%= document_root %>/shop.polymer-project.org.conf /etc/nginx/sites-enabled/shop.polymer-project.org.conf"
echo "5. On server: sudo nginx -t # verify configs"
echo "6. On server: sudo systemctl restart nginx # activate new site"
