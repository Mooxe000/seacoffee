#
# util-path.js
#   - The utilities for operating path such as id, uri
#

utilLang = require './util-lang'
{isString} = utilLang
{isFunction} = utilLang
utilDom = require './util-dom'
{getLoaderScript} = utilDom
{getScriptAbsoluteSrc} = utilDom

getData = -> seajs.getData()

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

# 依次 从 seajs.config [alias, paths, vars] 中查找模块 url
parseAlias = (id) ->
  data = getData()
  {alias} = data
  return id unless alias?
  if isString alias[id]
    alias[id]
  else id

parsePaths = (id) ->
  data = getData()
  {paths} = data
  return id unless paths?
  if id.match RE.PATHS and isString paths[m[1]]
    id = paths[m[1]] + m[2]
  id

parseVars = (id) ->
  data = getData()
  {vars} = data
  return id unless vars?
  if id.indexOf "{" > -1
    id = id.replace RE.VARS, (m, key) ->
      if isString vars[key] then vars[key] else m
  id

parseMap = (uri) ->
  data = getData()
  {map} = data
  return uri unless map?
  ret = uri
  for rule in map
    if isFunction rule
      ret = rule(uri) or uri
    else
      ret = uri.replace rule[0], rule[1]
    # Only apply the first matched rule
    break unless ret is uri
  ret

addBase = (id, refUri) ->
  data = getData()
  first = id.charAt 0

  # Absolute
  # online url like 'http://'
  if RE.ABSOLUTE.test id
    ret = id

  # Relative './blabla/blabla'
  # 相对路径
  else if first is "."
    ret = realpath (if refUri? then dirname refUri else cwd) + id

  # Root '/blabla/blabla'
  # 绝对路径
  else if first is "/"
    m = data.cwd.match RE.ROOT_DIR
    ret = if m then m[0] + id.substring 1 else id

  # Top-level
  else ret = data.base + id
  
  # Add default protocol when uri begins with "//"
  ret = location.protocol + ret if ret.indexOf("//") is 0
  ret

id2Uri = (id, refUri) ->
  return '' unless id?
  id = parseAlias id
  id = parsePaths id
  id = parseVars id
  id = normalize id
  uri = addBase id, refUri
  uri = parseMap uri
  uri

exports.RE = RE
exports.dirname = dirname
exports.cwd = cwd
exports.getLoaderDir = getLoaderDir
exports.realpath = realpath
exports.normalize = normalize
exports.parseAlias = parseAlias
exports.parsePaths = parsePaths
exports.parseVars = parseVars
exports.parseMap = parseMap
exports.addBase = addBase
exports.id2Uri = id2Uri
