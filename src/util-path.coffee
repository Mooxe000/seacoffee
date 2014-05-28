#
# util-path.js
#   - The utilities for operating path such as id, uri
#

utilDom = require './util-dom'
{getLoaderScript} = utilDom
{getScriptAbsoluteSrc} = utilDom

RE =
  DIRNAME: /[^?#]*\//
  DOT: /\/\.\//g
  DOUBLE_DOT: /\/[^/]+\/\.\.\//
  MULTI_SLASH: /([^:/])\/+\//g
  PATHS: /^([^/:]+)(\/.+)$/
  VARS: /{([^{]+)}/g
  ABSOLUTE: /^\/\/.|:\//
  ROOT_DIR: /^.*?\/\/.*?\//

# Extract the directory portion of a path
# dirname("a/b/c.js?t=123#xx/zz") ==> "a/b/"
# ref: http://jsperf.com/regex-vs-split/2
dirname = (path) -> path.match(RE.DIRNAME)[0]

cwd = ->
  if location.href?
    dirname location.href
  else '' # TODO else return what

# When `sea.js` is inline, set loaderDir to current working directory
getLoaderDir = ->
  loaderScript = getLoaderScript()
  dirname getScriptAbsoluteSrc(loaderScript) or cwd()

# Canonicalize a path
# realpath("http://test.com/a//./b/../c") ==> "http://test.com/a/c"
# 规范 URL
realpath = (path) ->
  # /a/b/./c/./d ==> /a/b/c/d
  path = path.replace RE.DOT, "/"
  # @author wh1100717
  # a//b/c ==> a/b/c
  # a///b/////c ==> a/b/c
  # DOUBLE_DOT_RE matches a/b/c//../d path correctly only if replace // with / first
  path = path.replace RE.MULTI_SLASH, "$1/"
  # a/b/c/../../d  ==>  a/b/../d  ==>  a/d
  path = path.replace RE.DOUBLE_DOT, "/" while path.match RE.DOUBLE_DOT
  path

# Normalize an id
# normalize("path/to/a") ==> "path/to/a.js"
# NOTICE: substring is faster than negative slice and RegExp
# 注意：substring 比 slice & RegExp 执行效率高
normalize = (path) ->
  # 去除末尾 '#' # If the uri ends with `#`, just return it without '#'
  last = path.length - 1
  lastC = path.charAt last
  lastjs = path.substring last - 2
  lastcss = path.substring last - 3

  if lastC is "#"
    path.substring(0, last)
  else if lastjs is ".js" or lastcss is ".css" or path.indexOf("?") > 0 or lastC is "/"
    path
  else # 默认无后缀识别为 js
    path + ".js"

exports.RE = RE
exports.dirname = dirname
exports.cwd = cwd
exports.getLoaderDir = getLoaderDir
exports.realpath = realpath
exports.normalize = normalize
