#!/usr/bin/env coffee

chrome = require '../lib/chrome'
cli = require './cli'

# don't do anything unless we executed this module directly
unless module.parent
  opts =
    hostname: "127.0.0.1"
    port: 9515
    pathname: "/wd/hub"
    args: [
      "--url-base=/wd/hub"
      "--port=" + 9515
      "--verbose"
    ]
  chrome.init(opts, cli.run)


