#!/usr/bin/env coffee
###
  REQUIRE
###
require 'shelljs/global'
echo = console.log
inspect = require('util').inspect
path = require 'path'
{join} = path

gulp = require 'gulp'
debug = require 'gulp-debug'
es = require 'event-stream'
tap = require 'gulp-tap'
gutil = require 'gulp-util'
log = gutil.log

runSequence = require 'run-sequence'
clean = require 'gulp-clean'
compile = require 'gulp-compile-js'
concat = require 'gulp-concat'
wrap = require 'gulp-wrap'
frep = require 'gulp-frep'
uglify = require 'gulp-uglify'
rename = require 'gulp-rename'
gulpGrp = require 'gulp-filter'
beautify = require 'gulp-beautify'
order = require 'gulp-order'
plumber = require 'gulp-plumber'

###
  PATH
###
srcpath = join __dirname, './src'
dstpath = join __dirname, './dist'
libpath = join __dirname, './test/specs/@base/lib'
nodpath = join __dirname, './node_modules'

VERSION = '2.3.0'

modgrp = [
  'util-lang'
  'util-dom'
  'util-deps'
  'util-path'
  'util-events'
  'util-request'
  'util-debug'
  'config'
  'config.id2uri'
  'data'
  'module'
  'module.define'
  'module.use'
]

seaModule = do ->
  r_modgrp = modgrp.slice 0
  r_modgrp.unshift 'sea'
  r_modgrp.push 'api'
  r_modgrp

seaModPath = do ->
  r_seaModule = []
  for seamod in seaModule
    r_seaModule.push "src/#{seamod}.coffee"
  r_seaModule

modGrpPath = do ->
  r_modgrp = []
  for mod in modgrp
    r_modgrp.push "**/#{mod}.js"
  r_modgrp
modGrp = gulpGrp modGrpPath

LicenseDEC = "Sea.js #{VERSION} | seajs.org/LICENSE.md"
wrapStr =
  head: """
  /**
   * #{LicenseDEC}
   */
  (function(global, undefined) {
    var require;
    require = function(path) {
      return require[path];
    };
  """
  foot: """
  })(this);
  """
repVersion = [
  pattern: /@VERSION/
  replacement: "#{VERSION}"
]

wrapMod = (file) ->
  extname = path.extname file.path
  basename = path.basename file.path, extname
  contents = """
      require['./#{basename}'] = (function() {
        var module, exports;
        exports = {}; module = {exports: exports};
        #{file.contents}
        return module.exports;
      })();\n
    """
  file.contents = Buffer.concat [
    new Buffer contents
  ]

###
  BUILD TASKS
###
gulp.task 'echo', ->
  echo seaModule
  echo seaModPath
  echo utilGrpPath

gulp.task 'clean', ->
  gulp.src dstpath
  .pipe clean()

  gulp.src libpath
  .pipe clean()

gulp.task 'build', ->
  gulp.src seaModPath
  .pipe do plumber
  # compile coffee
  .pipe compile
    coffee:
      bare: true
  # wrap modGrp
  .pipe modGrp
  .pipe tap wrapMod
  .pipe concat 'modGrp.js'
  .pipe modGrp.restore()
  .pipe order [
    '**/sea.js'
    '**/modGrp.js'
    '**/api.js'
  ]
  # file list
  #.pipe tap (file) ->
  #  filename = path.basename file.path, path.extname file.path
  #  echo filename
  # ---------
  .pipe concat 'sea-debug.js'
  .pipe wrap """
    #{wrapStr.head}
    <%= contents %>
    #{wrapStr.foot}
    """
  .pipe frep repVersion
  .pipe beautify
      indentSize: 2
  .pipe gulp.dest dstpath
  .pipe rename (dir) ->
    return {
      dirname: dir.dirname
      basename: 'sea'
      extname: dir.extname
    }
  .pipe uglify()
  .pipe wrap """
    /*! #{LicenseDEC} */
    <%= contents %>
    """
  .pipe gulp.dest dstpath

gulp.task 'dmplib', ->
  gulp.src join dstpath, '/*'
  .pipe gulp.dest libpath

  mochaPath = join nodpath, '/mocha'
  chaiPath = join nodpath, '/chai'
  chaipromisedPath = join nodpath, '/chai-as-promised'
  qPath = join nodpath, '/q'

  gulp.src [(join mochaPath, '/mocha.css'), (join mochaPath, '/mocha.js')]
  .pipe gulp.dest libpath

  gulp.src (join chaiPath, '/chai.js')
  .pipe gulp.dest libpath

  gulp.src (join qPath, '/q.js')
  .pipe gulp.dest libpath

  gulp.src (join chaipromisedPath, '/lib/chai-as-promised.js')
  .pipe gulp.dest libpath

gulp.task 'default', ->
  runSequence 'clean', 'build', 'dmplib'

gulp.task 'rungulp', ->
  cd __dirname
  exec 'gulp'

gulp.task 'watch', ->
  gulp.watch seaModPath, ['rungulp']
