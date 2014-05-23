#!/usr/bin/env coffee
require 'shelljs/make'
echo = console.log

target.all = ->
  packages = [
    'gulp'
    'gulp-util'
    'gulp-debug'
    'event-stream'
    'gulp-tap'
    'gulp-plumber'
    'run-sequence'
    'gulp-clean'
    'gulp-rename'
    'gulp-compile-js'
    'gulp-concat'
    'gulp-wrap'
    'gulp-frep'
    'gulp-uglify'
    'gulp-filter'
    'gulp-beautify'
    # TEST
    'phantomjs'
    'phantom'
    'mocha'
    'mocha-phantomjs'
    'chai'
    'karma'
    'karma-cli'
    'karma-mocha'
    'karma-chai'
    'karma-mocha-reporter'
    'karma-spec-reporter'
    'karma-phantomjs-launcher'
    'karma-coffee-preprocessor'
    'karma-jade-preprocessor'
    'karma-html2js-preprocessor'
  ]
  for pkg in packages
    exec "npm install #{pkg}"
