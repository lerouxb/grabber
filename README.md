grabber
=======

Installation
------------

See sharp's instructions for installing
[libvips](https://github.com/lovell/sharp#installation). Sharp is used to
resize screenshots and turn them into JPEG, PNG or WebP images.

After that a simple `npm install grabber` should do the trick.
ChromeDriver is straight-forward to install via npm install, but if you want to
use Firefox to take screenshots you'll have to be running Selenium server.

If you want ChromeDriver to be started by grabber.chrome you'll also have to
`npm install chromedriver`. It is a relatively large and platform-dependent
dependency, so it isn't in package.json. Alternatively you can keep it running
in the background just like you would with the Selenium server.

Try out some of these guides for getting Xvfb and Selenium running so that you
can take "headless" screenshots in a Linux environment. You probably don't want
to be screenshotting in OSX or Windows or a real (non-framebuffer) X server
because the browser window is going to pop up.

* [Running Headless Selenium with Chrome](http://www.chrisle.me/2013/08/running-headless-selenium-with-chrome/)
* [Headless Chrome/Firefox testing in NodeJS with Selenium and Xvfb](http://codeutopia.net/blog/2013/07/13/headless-chromefirefox-testing-in-nodejs-with-selenium-and-xvfb/)
* [Use Xvfb, Selenium and Chrome to drive a web browser in PHP](http://www.yann.com/en/use-xvfb-selenium-and-chrome-to-drive-a-web-browser-in-php-23/08/2012.html)


Limitations
-----------

Both Firefox and Chrome seem to have the limitation that you can't resize the
browser window to be larger than the screen, so you're limited by your screen
dimensions. In Linux you can probably get around this to some extent using
Xvfb.

Chrome cannot take a screenshot of the full page and will only screenshot the
visible portion. Firefox can screenshot the entire page, but this library
doesn't allow for that just yet.


Usage
-----

```coffeescript
grabber = require 'grabber'

chromeOptions =
  startChrome: false # set to true to start chromedriver in a subprocess
  hostname: "127.0.0.1"
  port: 9515
  pathname: "/wd/hub"
  args: [
    "--url-base=/wd/hub"
    "--port=" + 9515
    "--verbose"
  ]

browser = grabber.chrome.init(chromeOptions, (err, browser) ->
  return console.error(err) if err

  screenshotOptions =
    url: 'http://www.google.com/'
    width: 1024
    height: 768
    resize: 512
    quality: 80

    # see browser.waitForConditionInBrowser in wd
    condition: "document.querySelectorAll('.foo').length > 0"

    # see wd for documentation on browser
    cleanup: (browser, cb) ->
      # Do something with browser like dismiss popups or scroll down to the
      # button of the page or whatever you want to do before you take a
      # screenshot.
      cb() # remember to call cb() when you're done

    # save the file
    out: 'google.jpg'

  grabber.commands.screenshot browser, screenshotOptions, (err, image) ->
    return console.error(err) if err
    # image now contains an instance of a sharp image object thing that you can
    # then do something with if you want. Probably not necesary if you passed
    # in an out parameter
```

Examples
--------

Most of the action happens in the examples/ directory.

**chrome_screenshot.coffee** and **firefox_screenshot.coffee** are command-line
utilities to take screenshots.

The parameters are url, width, height, resize, quality, crop. The CLI utilities
also take an --out=filename.(png|jpeg|webp) parameter and support a -t
parameter for testing with [Thing's](http://thing.io/) settings.

