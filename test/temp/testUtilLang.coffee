#!/usr/bin/env coffee
echo = console.log
require 'shelljs/make'
utilLang = require './../../src/util-lang'

target.all = ->
  echo 'Test Object:'
  a = {}
  echo '  isObject: ' + utilLang.isObject a
  echo '  isString: ' + utilLang.isString a
  echo '  isArray: ' + utilLang.isArray a
  echo '  isFunction: ' + utilLang.isFunction a
  echo ''

  echo 'Test String'
  b = 'Hello World'
  echo '  isObject: ' + utilLang.isObject b
  echo '  isString: ' + utilLang.isString b
  echo '  isArray: ' + utilLang.isArray b
  echo '  isFunction: ' + utilLang.isFunction b
  echo '\n'

  echo 'Test Array'
  c = []
  echo '  isObject: ' + utilLang.isObject c
  echo '  isString: ' + utilLang.isString c
  echo '  isArray: ' + utilLang.isArray c
  echo '  isFunction: ' + utilLang.isFunction c
  echo ''

  echo 'Test Function'
  d = -> echo b
  echo '  isObject: ' + utilLang.isObject d
  echo '  isString: ' + utilLang.isString d
  echo '  isArray: ' + utilLang.isArray d
  echo '  isFunction: ' + utilLang.isFunction d
  echo ''
