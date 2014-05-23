#!/usr/bin/env coffee
echo = console.log
phantom = require 'phantom'
path = require 'path'
jade = require 'jade'

#seajs = path.join __dirname, './../dist/sea-debug.js'
#
#phantom.create (ph) ->
#  ph.injectJs seajs
#  ph.exit()

phantom.create (ph) ->
  ph.createPage (page) ->
    page.open 'http://localhost:9000/', (status) ->
      echo 'opened page? ' + status
      page.evaluate ->
          typeof seajs
          seajs.config
            alias:
              main: '/specs/config/alias/main'
              a: '/specs/config/alias/path/to/a.js'
              'biz/b': '/specs/config/alias/path/to/biz/b'
          seajs.use 'main'
        , (result) ->
          ph.exit()
