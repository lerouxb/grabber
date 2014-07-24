#!/usr/bin/env coffee

firefox = require '../lib/firefox'
cli = require './cli'

# don't do anything unless we executed this module directly
unless module.parent
  opts =
    hostname: "127.0.0.1"
    port: 4444
    pathname: "/wd/hub"
  firefox.init(opts, cli.run)


