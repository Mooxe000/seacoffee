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

###
  PATH
###
srcpath = join __dirname, './src'
dstpath = join __dirname, './dist'
libpath = join __dirname, './test/specs/@base/lib'
nodpath = join __dirname, './node_modules'

VERSION = '2.3.0'

seaModule = [
  'sea'
  'util-lang'
  'util-dom'
  'util-deps'
  'util-path'
  'util-events'
  'util-request'
  'data'
  'module'
  'Api'
]

seaModPath = ->
  seaModule_r = []
  for seamod in seaModule
    seaModule_r.push "src/#{seamod}.coffee"
  seaModule_r

utilGrp = gulpGrp '**/util-*.js'
moduleGrp = gulpGrp '**/module.js'
dataGrp = gulpGrp '**/data.js'
apiGrp = gulpGrp '**/Api.js'

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
gulp.task 'clean', ->
  gulp.src dstpath
  .pipe clean()

  gulp.src libpath
  .pipe clean()

gulp.task 'build', ->
  gulp.src seaModPath()
  # compile coffee
  .pipe compile
    coffee:
      bare: true
  # wrap utils
  .pipe utilGrp
  .pipe tap wrapMod
  .pipe concat 'util.js'
  .pipe utilGrp.restore()
  # wrap module
  .pipe moduleGrp
  .pipe tap wrapMod
  .pipe concat 'module.js'
  .pipe moduleGrp.restore()
  # wrap data
  .pipe dataGrp
  .pipe tap wrapMod
  .pipe concat 'data.js'
  .pipe dataGrp.restore()
  # api
  .pipe apiGrp
  .pipe concat 'api.js'
  .pipe apiGrp.restore()
  # file list
  .pipe tap (file) ->
    filename = path.basename file.path, path.extname file.path
    echo filename
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
