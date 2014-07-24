thing = require './thing'
commands = require '../lib/commands'
argv = require("minimist")(process.argv.slice(2))

run = (err, browser) ->
  return console.error(err) if err

  # clone
  opts = {}
  for k, v of argv
    opts[k] = v

  # t == thing
  if opts.t
    for k, v of thing.getOptions()
      opts[k] = v

  commands.screenshot browser, opts, (err) ->
    console.error(err) if err
    # done and exit regardless of error
    console.log "done."
    browser.exit()

module.exports =
  run: run
