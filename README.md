# prpl-rain
Tools for setting up Google Compute Engine resources for hosting PRPL apps
(such as shop.polymer-project.org and news.polymer-project.org)

## The PRPL Rain Server Configuration

We deployed to GCE (Google Compute Engine) and everything here works if you do
the same.  However, you could apply this to another provider with very little
modification.

Current architecture of our servers required explicit installation of only
two packages: nghttpx and nginx on GCE instances using latest Ubuntu image (at
time of writing: "Ubuntu 16.10 - amd64 yakkety built on 2017-01-03").

## Why does this repo contain all those Ruby scripts?

There are a collection of simple command line scripts, written in [Ruby][], for
doing simple tasks associated with the configuration and deployment of the
instances.  At some point we may decide to port these to TypeScript and node
like all our standard tools, but these Ruby scripts were more expedient for
me to write and use to get these deployments done.  Alternatively, we may add
features into polymer-cli to do some of this stuff.  There's nothing special
about the code being in Ruby other than its terse and I could write it faster.

If you don't have Ruby installed (unlikely), I recommend using [rbenv][] and
[ruby-build][] to install and manage it.

## How to I configure a PRPL rain server on GCE?

There aren't many steps.  Here they are:

 1. Create a VM instance on GCE (preferably Ubuntu)
 2. Put your SSL certs onto the instance somewhere
 3. Install the nghttp2 package, containing the nghttpx proxy server
 4. Generate nghttpx config
 5. Put the nghttpx config on the server
 6. Restart nghttpx service
 7. Install nginx
 8. Disable the `default` nginx site
 9. Enable the `unknown-hosts-kthxbye.conf` site
 10. Restart nginx service

Now, how to deploy an app?  Lets look at the build script in an example.
`examples/news.polymer-project.org/build.rb`

If we run that it will, clone the news repo, run polymer build, then generate
server configs for nginx and put them in `build/unbundled/.nginx`.  It outputs
a few instructions when its done:

```
1. Copy the /Users/brendanb/src/github.com/polymerlabs/prpl-rain/examples/news.polymer-project.org/news.git/build/unbundled folder to the server at /var/www/news.polymer-project.org
2. On server: sudo chown -R root /var/www/news.polymer-project.org
3. On server: sudo chgrp -R root /var/www/news.polymer-project.org
4. On server: sudo ln -s /var/www/news.polymer-project.org/news.polymer-project.org.conf /etc/nginx/sites-enabled/news.polymer-project.org.conf
5. On server: sudo nginx -t # verify configs
6. On server: sudo systemctl restart nginx # activate new site
```

TODO(usergenic): gcloud commands to facilitate automatic deployment...
TODO(usergenic): finish README.

[Ruby]: https://www.ruby-lang.org/en/
[rbenv]: https://github.com/rbenv/rbenv
[ruby-build]: https://github.com/rbenv/ruby-build
