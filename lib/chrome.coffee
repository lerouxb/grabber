# This file is based on https://gist.github.com/malandrew/5e4a7a30a0706ef50c0c

wd = require "wd"

chromedriverIsReady = (opts, stdout) ->
  return false if stdout.indexOf("Starting ChromeDriver") == -1
  return false if stdout.indexOf("on port " + opts.port) == -1
  return false if stdout.indexOf("Only local connections are allowed.") == -1
  true

init = (opts, callback) ->
  chrome = null

  continueAfterStart = ->
    browser = wd.remote(
      hostname: opts.hostname
      port: opts.port
      pathname: opts.pathname
    )

    # convenient method so we don't have to pass 'chrome' around
    browser.exit = (cb) ->
      browser.quit ->
        chrome.kill("SIGHUP") if opts.startChrome
        cb() if cb

    browser.init
      browserName: "chrome"
      chromeOptions:
        args: ['--test-type']
    , (err) ->
      callback(err, browser)


  return continueAfterStart() unless opts.startChrome

  # ----

  # start chrome in a subprocess first and only connect to it once it runs
  spawn = require("child_process").spawn
  chromedriver = require "chromedriver"

  chrome = spawn(chromedriver.path, opts.args)
  started = false

  # only going to keep this until the browser started because otherwise it is
  # going to just grow and grow forever
  stdout = ""
  stderr = ""

  chrome.stdout.on "data", (data) ->
    #console.log ""+data
    stdout += data unless started
    return unless chromedriverIsReady(opts, stdout) and not started

    console.log "started"
    started = true
    continueAfterStart()

  chrome.stderr.on "data", (data) ->
    #console.error ""+data
    stderr += data unless started

  chrome.on "close", (code, signal) ->
    console.log "child process exited with code %d and signal %s", code, signal

module.exports =
  init: init
