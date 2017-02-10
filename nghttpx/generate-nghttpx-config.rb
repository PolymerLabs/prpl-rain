#!/usr/bin/env ruby

key_file = ARGV[0] || '/etc/ssl/private/www.example.com.key'
crt_file = ARGV[1] || '/etc/ssl/private/www.example.com.chained.pem'

__END__

frontend=0.0.0.0,443
backend=127.0.0.1,8080
private-key-file=<%= key_file %>
certificate-file=<%= crt_file %>
http2-proxy=no
workers=1
accesslog-file=/var/log/nghttpx/access.log
errorlog-file=/var/log/nghttpx/error.log
