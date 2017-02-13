#!/usr/bin/env ruby

# TODO(usergenic): Port script to a unified builder with a couple of options.
# This file generates the link header directives from the firebase.json file
# I took from the firebase branch of https://github.com/Polymer/news,
# generates server config for news.polymer-project.org and then builds the
# news app and copies configs into an .nginx folder in the unbundled build
# output.  This makes that folder suitable to upload as is.

require 'erb'

script_dir = File.expand_path(File.dirname(__FILE__))
root_dir = File.expand_path(File.join(script_dir, '../..'))
repo_dir = File.join(script_dir, 'news.git')
firebase_json = File.join(script_dir, 'firebase.json')
document_root = '/var/www/news.polymer-project.org'

system ERB.new(DATA.read).result

__END__

rm -rf <%= repo_dir %>/build
if [ ! -d "<%= repo_dir %>" ]; then
  git clone git@github.com:Polymer/news.git <%= repo_dir %>
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

<%= root_dir %>/nginx/generate-server-config.rb news.polymer-project.org > \
    build/unbundled/.nginx/news.polymer-project.org.conf

<%= root_dir %>/firebase/extract-url-preload-headers.rb < <%= firebase_json %> \
    | <%= root_dir %>/core/preload-urls-to-link-header-values.rb \
    | <%= root_dir %>/nginx/generate-preload-header-directives.rb > \
    build/unbundled/.nginx/location-includes/link-headers.conf

cp <%= script_dir %>/rewrite-articles-for-bots.conf \
    build/unbundled/.nginx/path-includes/rewrite-articles-for-bots.conf

echo "1. Copy the <%= repo_dir %>/build/unbundled folder to the server at <%= document_root %>"
echo "2. On server: sudo chown -R root <%= document_root %>"
echo "3. On server: sudo chgrp -R root <%= document_root %>"
echo "4. On server: sudo ln -s <%= document_root %>/news.polymer-project.org.conf /etc/nginx/sites-enabled/news.polymer-project.org.conf"
echo "5. On server: sudo nginx -t # verify configs"
echo "6. On server: sudo systemctl restart nginx # activate new site"
