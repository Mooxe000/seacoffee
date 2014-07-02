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
{isArray} = utilLang
{isObject} = utilLang
utilEvents = require './util-events'
{emit} = utilEvents
getdata = -> seajs.data

class Config
  constructor: ->
    @debug = false
    # The charset for requesting files
    @charset = 'utf-8'
    @ids = []

  @idfields = [
    'base'
    'alias'
    'paths'
    'vars'
    'map'
  ]

  @config: (configData) ->
    data = do getdata
    curConfig = do data.getconfig
    {idfields} = Config

    # debug
    curConfig.debug = configData.debug if configData.debug?
    # charset
    curConfig.charset = configData.charset if configData.charset?

    # curids
    return if 0 >= do ->
      count = 0
      for dataField of configData
        count++ unless idfields.indexOf(dataField) is -1
      count
    curIds = curConfig.ids

    # tmpid
    tmpid = {}
    for idfield in idfields
      tmpid[idfield] = configData[idfield] if configData[idfield]?

    # baseArr
    curLen = curIds.length
    baseArr = do ->
      return [] if curLen is 0
      baseArr = []
      for curid in curIds
        baseArr.push curid.base
      baseArr

    mergeId = (curid, newid) ->
      for field of newid
        if isArray newid[field]
          if isArray curid[field]
            curid[field].concat newid[field]
          else
            curid[field].push newid[field]
        else if isObject newid[field]
          if isObject curid[field]
            for key of newid[field]
              curid[field][key] = newid[field][key]
          else
            curid[field] = newid[field]
        else curid[filed] = newid[field]

    # merge curid tmpid
    if curLen is 0
      tmpid.base = getLoaderDir() unless tmpid.base?
      curIds.push tmpid
    else
      if tmpid.base?
        if baseArr.indexOf(tmpid.base) isnt -1
          curid = curIds[baseArr.indexOf tmpid.base]
          mergeId curid, tmpid
        else
          curIds.push tmpid
      else
        curid = curIds[curIds.length - 1]
        mergeId curid, tmpid

    return

module.exports = Config
