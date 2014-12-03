name        'rsyslog'
description 'Configures rsyslog to use UDP or TCP to send files remotely'
maintainer  'doomspork'
license     'MIT'
version     '1.0.0'

recipe 'ryslog::setup', 'Set up rsyslog'

attribute 'remotes',
  display_name: 'Collection of remote services',
  description: 'The remote service name and URL (e.g. { "papertail": "*.* @udp.example.com:41001" }',
  type: 'hash'
