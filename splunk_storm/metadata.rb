name        'splunk_storm'
description 'Configures Splunk Storm to work with rsyslog'
maintainer  'doomspork'
license     'MIT'
version     '1.0.0'

recipe 'splunk_storm::setup', 'Set up rsyslog and Splunk Storm.'

attribute 'hostname',
  display_name: 'SplunkStorm TCP hostname',
  description: 'The hostname provided under Inputs > Network data',
  type: 'string'

attribute 'port',
  display_name: 'SplunkStorm TCP port',
  description: 'The port provided under Inputs > Network data',
  type: 'string'
