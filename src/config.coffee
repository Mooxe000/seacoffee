#
# config.js
#   - The configuration for the loader
#
# seajs.data.config = []
#
# 将 config 4 件套 打包 成 config 对象
# base: 一旦 base 更新，则新建一个实例并 push 到 config array 中
# 查找则倒序查找
#
# config[num].alias
#   - An object containing shorthands of module id
#   - 设置 模块 ID 别名
# config[num].paths
#   - An object containing path shorthands in module id
#   - 设置 模块 路径 别名
# config[num].vars
#   - The {xxx} variables in module id
#   - 设置 模块 ID 变量 别名
# config[num].map
#   - An array containing rules to map module uri
#   - 一个 模块 键值对 列表
#
# How to config
#   - https://github.com/seajs/seajs/issues/262
#

utilLang = require './util-lang'
{isString} = utilLang
{isFunction} = utilLang
{isArray} = utilLang
{isObject} = utilLang
utilEvents = require './util-events'
{emit} = utilEvents
utilPath = require './util-path'
{RE} = utilPath
{getLoaderDir} = utilPath
{normalize} = utilPath
{realpath} = utilPath
{dirname} = utilPath
{cwd} = utilPath

class Config

  constructor: (configData) ->
    for field in Config.fields
      @[field] = configData[field] if configData[field]?
    return @

  getCfg = ->
    seajs.data.config = [] unless seajs.data.config?
    seajs.data.config

  @fields = [
    'base'
    'alias'
    'paths'
    'vars'
    'map'
  ]

  # check field
  countField = (configData) ->
    count = 0
    for dataField of configData
      count++ unless Config.fields.indexOf(dataField) is -1
    count

  @config: (configData) ->
    # check seajs.config
    configArr = getCfg()
    # check field
    count = countField configData
    return if count <= 0
    # mount to seajs
    len = configArr.length
    # create new config obj
    if len is 0 or configData.base?
      configNew = new Config(configData)

      # check base
      unless configNew.base?
        if len is 0
          config.base = getLoaderDir()
        else
          config.base = configArr[len - 1]

      # other field
      for field in Config.fields
        configNew[field] = configData[field]

      configArr.push configNew
    else # merge into last config obj
      config = configArr[len - 1]
      for field of configData
        if isArray config[field]
          if isArray configData[field]
            config[field].concat configData[field]
          else
            config[field].push configData[field]
        else if isObject config[field]
          if isObject configData[field]
            for key of configData[field]
              config[field][key] = configData[field][key]
          else
            # TODO Handle ERR
        else
          config[field] = configData[field]

    emit "config", configData
    return

  # 从 config alias 中查找模块 url
  parseAlias = (id, configData) ->
    {alias} = configData
    return null unless alias?
    if isString alias[id]
      alias[id]
    else null

  parsePaths = (id, configData) ->
    {paths} = configData
    return id unless paths?
    m = id.match RE.PATHS
    if m? and isString paths[m[1]]
      id = paths[m[1]] + m[2]
    id

  parseVars = (id, configData) ->
    {vars} = configData
    return id unless vars?
    if id.indexOf "{" > -1
      id = id.replace RE.VARS, (m, key) ->
        if isString vars[key] then vars[key] else m
    id

  addBase = (id, configData, refUri) ->
    {base} = configData
    first = id.charAt 0
    # Absolute
    # online url like 'http://'
    if RE.ABSOLUTE.test id
      ret = id

    # Relative './blabla/blabla'
    # 相对路径
    else if first is "."
      ret = realpath (if refUri? then dirname refUri else cwd()) + id

    # Root '/blabla/blabla'
    # 绝对路径
    else if first is "/"
      m = cwd().match RE.ROOT_DIR
      ret = if m then m[0] + id.substring 1 else id

    # Top-level
    else
      if base.charAt(base.length - 1) isnt '/' and id.charAt(0) isnt '/'
        ret = base + '/' + id
      else
        ret = base + id
    ret

  parseMap = (uri, configData) ->
    {map} = configData
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

  @id2Uri: (id, refUri) ->
    configArr = getCfg()
    return unless id? or configArr.length is 0

    configArr_rev = configArr.slice(0).reverse()
    for _configData_ in configArr_rev
      _id_ = parseAlias id, _configData_
      unless _id_?
        continue
      else
        id = _id_ if _id_?
        configData = _configData_
        break

    unless _id_?
      configData = configArr[configArr.length - 1]
      configArr[configArr.length - 1].alias = {} unless configData.alias?
      configArr[configArr.length - 1].alias[id] = id

#      configData = configArr[configArr.length - 1]
#      _id_ = parseAlias id, configData
#      if _id_?
#        id =  _id_
#      else
#        alias = configArr[configArr.length - 1].alias
#        configArr[configArr.length - 1].alias = {} unless alias?
#        configArr[configArr.length - 1].alias[id] = id

    id = parsePaths id, configData
    id = parseVars id, configData
    id = normalize id
    uri = addBase id, configData, refUri
    uri = parseMap uri, configData
    uri

module.exports = Config
