wd = require "wd"

init = (opts, callback) ->
  browser = wd.remote(opts)

  browser.exit = (cb) ->
    cb ?= ->
    browser.quit cb

  browser.init
    browserName: "firefox"
  , (err) ->
    callback(err, browser)

module.exports =
  init: init
