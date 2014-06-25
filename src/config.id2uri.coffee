utilLang = require './util-lang'
{isString} = utilLang
{isFunction} = utilLang
utilPath = require './util-path'
{RE} = utilPath
{realpath} = utilPath
{normalize} = utilPath
{cwd} = utilPath

getdata = -> seajs.data

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

parseMap = (id, configData) ->
  {map} = configData
  return id unless map?
  ret =id
  for rule in map
    if isFunction rule
      ret = rule(id) or id
    else
      ret = id.replace rule[0], rule[1]
    # Only apply the first matched rule
    break unless ret is id
  ret

id2uri = (id) ->

  data = do getdata
  configDatas = data.getconfig().ids

  # Absolute
  # online url like 'http://'
  # uri resource
  until RE.ABSOLUTE.test id
    first = id.charAt 0

    # Relative './blabla/blabla'
    # 相对路径
    if first is "."
      id = realpath "#{cwd()}/#{id}"

    # Root '/blabla/blabla'
    # 绝对路径
    else if first is "/"
      m = cwd().match RE.ROOT_DIR
      id = if m then m[0] + id.substring 1 else id

    # alias
    else
      configDatas_rev = configDatas.slice(0).reverse()

      for _configData_ in configDatas_rev
        _id_ = parseAlias id, _configData_
        unless _id_?
          continue
        else
          id = _id_ if _id_?
          configData = _configData_
          break

      unless _id_?
        configData = configDatas[configDatas.length - 1]
        configData.alias = {} unless configData.alias?
        configData.alias[id] = id

      {base} = configData
      id = parsePaths id, configData
      id = parseVars id, configData
      id = normalize id
      id = parseMap id, configData
      id = realpath "#{base}/#{id}"

  id

module.exports = id2uri