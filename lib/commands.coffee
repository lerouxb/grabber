sharp = require 'sharp'

exports = module.exports


screenshot = exports.screenshot = (browser, opts, cb) ->
  # opts.url:       optional. don't specify if the page is already loaded
  # opts.width:     optional. defaults to 1024
  # opts.height:    optional. defaults to 768
  # opts.resize:    optional. width to resize the image to
  # opts.quality:   optional. defaults to 75
  # opts.condition: optional. js expression for browser
  # opts.cleanup:   optional. async function to run. gets browser parameter
  # opts.crop:      optional boolean. ignored for chrome
  # opts.out:       optional filename to save the screenshot to.
  # cb(error, image) where image is a a sharp image object thing

  opts.width ?= 1024
  opts.height ?= 768
  opts.quality ?= 80

  continueAfterLoad = ->
    if opts.condition
      console.log "waiting for #{opts.condition}"

      # should be enough...
      # (no idea why I have to set this here AND in waitForConditionInBrowser)
      browser.setAsyncScriptTimeout(60000)

      # total timeout, then poll interval
      browser.waitForConditionInBrowser opts.condition, 60000, 100, (err, b) ->
        return cb(err) if err

        if b
          continueAfterWait()

        else
          # I don't think it should be possible to get there because it should
          # just cause a timeout error, no?
          console.log "condition not met"
          cb new Error("condition not met")
    else
      continueAfterWait()

  continueAfterWait = ->
    if opts.cleanup
      console.log "running cleanup"
      opts.cleanup browser, (err, res) ->
        return cb(err) if err
        continueAfterCleanup()

    else
      continueAfterCleanup()

  continueAfterCleanup = ->
    resizeTo browser, opts.width, opts.height, ->
      console.log "screenshotting..."
      browser.takeScreenshot (err, base64Data) -> # err, base64Data
        return cb(err) if err
        image = sharp new Buffer(base64Data, 'base64')

        # this should probably be an option
        #image.bilinearInterpolation() # default
        #image.bicubicInterpolation()
        image.nohaloInterpolation()

        browserName = browser.defaultCapabilities.browserName
        if browserName == 'firefox' and opts.crop
          # we have to crop so that we don't screenshot the entire page, but
          # sharp can't chain multiple resize commands, so..
          console.log "cropping..."
          # TODO: there's no way to tell sharp to crop the top part rather than
          # the center, so this is effectively broken
          image.crop().resize(opts.width, opts.height).toBuffer (err, buff) ->
            return cb(err) if err
            # make a new image so we can continue resizing
            image = sharp buff
            continueAfterCrop image

        else
          # either this is chrome which doesn't support auto height anyway OR
          # it is firefox and we don't want the screenshot cropped to the
          # screen size
          continueAfterCrop image

  continueAfterCrop = (image) ->
    if opts.resize
      console.log "resizing..."
      continueAfterResize(image.resize(opts.resize))
    else
      continueAfterResize(image)

  continueAfterResize = (image) ->
    # not used for lossless png
    image.quality(opts.quality)

    if opts.out
      console.log "saving to #{opts.out}..."
      image.toFile opts.out, (err, info) ->
        cb(err, image)

    else
      cb(null, image)

  if opts.url
    console.log "loading #{opts.url}..."
    browser.get opts.url, (err) ->
      return cb(err) if err
      continueAfterLoad()
  else
    # you could load the page once, then take multiple screenshots
    # (for example)
    continueAfterLoad()

getDimensions = exports.getDimensions = (browser, cb) ->
  expression = "$w = $(window); [$w.width(), $w.height()]"
  browser.safeEval expression, (err, dimensions) ->
    if err
      cb err
    else
      cb null, dimensions[0], dimensions[1]

resizeTo = exports.resizeTo = (browser, targetWidth, targetHeight, cb) ->
  # set the window dimensions
  console.log "resizing to", targetWidth, targetHeight
  browser.setWindowSize targetWidth, targetHeight, ->
    getDimensions browser, (err, actualWidth, actualHeight) ->
      return cb(err) if err
      console.log "actual dimensions", actualWidth, actualHeight

      # compensate for the difference
      adjustedWidth = targetWidth + (targetWidth - actualWidth)
      adjustedHeight = targetHeight + (targetHeight - actualHeight)
      console.log "adjusted dimensions", adjustedWidth, adjustedHeight

      # set the new adjusted dimensions and wait a bit before continueing
      browser.setWindowSize adjustedWidth, adjustedHeight, ->
        console.log "giving the page a moment"
        setTimeout cb, 200 # wait 200ms for the page to adapt
