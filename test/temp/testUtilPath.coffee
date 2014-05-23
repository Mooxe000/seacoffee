#!/usr/bin/env coffee
echo = console.log
require 'shelljs/make'
utilPath = require './../../src/util-path'
{dirname} = utilPath
{realpath} = utilPath

target.all = ->
  pathname = 'a/b/c.js?t=123#xx/zz'
  echo dirname pathname

  pathname = 'http://test.com/a//./b/../c'
  echo realpath pathname