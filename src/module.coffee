#
# module.js
#   - The core of module loader
#
utilLang = require './util-lang'
{isObject} = utilLang
{isArray} = utilLang
{isFunction} = utilLang
utilPath = require './util-path'
{addBase} = utilPath
utilEvents = require './util-events'
{emit} = utilEvents
utilRequest = require './util-request'
{request} = utilRequest
utilDeps = require './util-deps'
{parseDependencies} = utilDeps
utilDom = require './util-dom'
{getCurrentScript} = utilDom
{getDoc} = utilDom

# 模块加载 的 六个 阶段
# 1 - The `module.uri` is being fetched
#   - 获取 模块 真实 url
# 2 - The meta data has been saved to cachedMods
#   - 获取模块缓存
# 3 - The `module.dependencies` are being loaded
#   - 加载依赖模块
# 4 - The module are ready to execute
#   - 准备执行
# 5 - The module is being executed
#   - 执行模块
# 6 - The `module.exports` is available
#   - 执行结束

getData = -> seajs.getData()

class Module

  constructor: (@uri, deps) ->
    @dependencies = deps or []
    @exports = null
    @status = 0
    @callback = null
    @_waitings = {}     # Who depends on me
    @_remain = 0        # The number of unloaded dependencies
    return @

  @STATUS:
    FETCHING: 1
    SAVED: 2
    LOADING: 3
    LOADED: 4
    EXECUTING: 5
    EXECUTED: 6

  # Resolve module.dependencies
  resolve: =>
    mod = @
    ids = mod.dependencies
    uris = []
    for id in ids
      uris.push Module.resolve id, mod.uri
    uris

  # Load module.dependencies and fire onload when all done
  load: =>
    mod = @
    data = getData()
    {cachedMods} = data
    {STATUS} = Module
    {get} = Module

    # If the module is being loaded, just wait it onload call
    # 检查状态，若已加载，则跳出
    return if mod.status >= STATUS.LOADING
    # 设置状态 为 LOADING
    mod.status = STATUS.LOADING

    uris = mod.resolve()
    mod._remain = uris.length

    # Emit `load` event for plugins such as combo plugin
    emit "load", uris

    # Initialize modules and register waitings
    for uri in uris
      m = get uri
      if m.status < STATUS.LOADED
        # Maybe duplicate: When module has dupliate dependency, it should be it's count, not 1
        m._waitings[mod.uri] = (m._waitings[mod.uri] or 0) + 1
      else
        mod._remain--
    if mod._remain is 0
      mod.onload()
      return

    # Begin parallel loading
    requestCache = {}
    if cachedMods?
      for uri in uris
        m = cachedMods[uri] if cachedMods[uri]?
        if m.status < STATUS.FETCHING
          m.fetch requestCache
        else m.load()

    # Send all requests at last to avoid cache bug in IE6-9. Issues#808
    for requestUri in requestCache
      requestCache[requestUri]() if requestCache.hasOwnProperty requestUri

    return

  # Call this method when module is loaded
  onload: =>
    mod = @
    {STATUS} = Module
    data = getData()
    {cachedMods} = data

    mod.status = STATUS.LOADED
    mod.callback() if mod.callback?

    waitings = mod._waitings
    # Notify waiting modules to fire onload
    for uri of waitings
      if waitings.hasOwnProperty(uri)
        m = cachedMods[uri]
        m._remain -= waitings[uri]
        m.onload() if m._remain is 0

    # Reduce memory taken
    delete mod._waitings
    delete mod._remain

    return

  # Fetch a module
  fetch: (requestCache) =>
    mod = @
    {STATUS} = Module
    data = getData()
    {fetchedList} = data
    {fetchingList} = data
    {callbackList} = data
    {charset} = data

    uri = mod.uri

    mod.status = STATUS.FETCHING

    # Emit `fetch` event for plugins such as combo plugin
    emitData = uri: uri
    emit "fetch", emitData
    requestUri = emitData.requestUri or uri

    # Empty uri or a non-CMD module
    if not requestUri or fetchedList[requestUri]
      mod.load()
      return
    if fetchingList[requestUri]
      callbackList[requestUri].push mod
      return

    fetchingList[requestUri] = true
    callbackList[requestUri] = [mod]

    onRequest = ->
      delete fetchingList[requestUri]

      fetchedList[requestUri] = true

      # Save meta data of anonymous module
      if anonymousMeta
        Module.save uri, anonymousMeta
        anonymousMeta = null

      # Call callbacks
      mods = callbackList[requestUri]
      delete callbackList[requestUri]

      m.load() while m = mods.shift()
      return

    emitData =
      uri: uri
      requestUri: requestUri
      onRequest: onRequest
      charset: charset

    # Emit `request` event for plugins such as text plugin
    emit "request", emitData

    sendRequest = ->
      request emitData.requestUri, emitData.onRequest, emitData.charset
      return

    unless emitData.requested
      if requestCache?
        requestCache[emitData.requestUri] = sendRequest
      else sendRequest()

    return

  # Execute a module
  exec: =>
    mod = @
    {STATUS} = Module
    {get} = Module
    {use} = Module
    {resolve} = Module

    # When module is executed, DO NOT execute it again. When module
    # is being executed, just return `module.exports` too, for avoiding
    # circularly calling
    return mod.exports if mod.status >= STATUS.EXECUTING
    mod.status = STATUS.EXECUTING

    # Create require
    {uri} = mod

    require = (id) -> get require.resolve(id).exec()
    require.resolve = (id) -> resolve id, uri
    require.async = (ids, callback) ->
      use ids, callback, uri + "_async_" + cid()
      require

    # Exec factory
    {factory} = mod
    exports = if isFunction factory then factory require, mod.exports = {}, mod else factory
    exports = mod.exports unless exports?

    # Reduce memory leak
    delete mod.factory

    mod.exports = exports
    mod.status = STATUS.EXECUTED

    # Emit `exec` event
    emit "exec", mod
    exports

  # The configuration for the loader
  # 配置 加载器
  # 配置 挂至 data 对象下
  # data.alias
  #   - An object containing shorthands of module id
  #   - 设置 模块 ID 别名
  # data.paths
  #   - An object containing path shorthands in module id
  #   - 设置 模块 路径 别名
  # data.vars
  #   - The {xxx} variables in module id
  #   - 设置 模块 ID 变量 别名
  # data.map
  #   - An array containing rules to map module uri
  #   - 一个 模块 键值对 列表
  # data.debug
  #   - Debug mode. The default value is false
  #   - Debug 模式，默认 不开启
  @config: (configData) ->
    data = getData()
    # 遍历 config 对象
    for key of configData
      curr = configData[key]      # 当前配置
      prev = data[key]            # 已加载配置

      # Merge object config such as alias, vars
      # 合并 当前配置与已加载配置项
      if prev? and isObject(prev) # 已加载配置存在 且 为对象 （遍历子对象）
        for k of curr             # 遍历 子对象
          prev[k] = curr[k]       # 将已加载配置同名键 值替换为当前配置
      else

        # Concat array config such as map
        # 配置项为 array 时，直接合并
        if isArray(prev)
          curr = prev.concat(curr)

          # Make sure that `data.base` is an absolute path
          # 既不为 obj，又不为 arr，对 base 做特殊处理
        else if key is "base"

          # Make sure end with "/"
          # 对 base 字段 末尾 补 “/”
          curr += "/"  if curr.slice(-1) isnt "/"
          curr = addBase curr    # 添加进 Base

        # Set config
        # 其他情况 挂至 seajs.data
        data[key] = curr
    emit "config", configData
    return

  # Resolve id to uri
  @resolve: (id, refUri) ->

    # Emit `resolve` event for plugins such as text plugin
    emitData =
      id: id
      refUri: refUri

    emit "resolve", emitData
    emitData.uri or id2Uri emitData.id, refUri

  # Define a module
  @define: (id, deps, factory) ->
    data = getData()
    {resolve} = Module
    {save} = Module
    argsLen = arguments.length

    # define(factory)
    if argsLen is 1
      factory = id
      id = `undefined`
    else if argsLen is 2
      factory = deps

      # define(deps, factory)
      if isArray(id)
        deps = id
        id = `undefined`

        # define(id, factory)
      else
        deps = `undefined`

    # Parse dependencies according to the module factory code
    deps = parseDependencies factory.toString() unless isArray(deps) and isFunction factory
    meta =
      id: id
      uri: resolve id
      deps: deps
      factory: factory

    doc = getDoc()
    # Try to derive uri in IE6-9 for anonymous modules
    if not meta.uri and doc.attachEvent
      script = getCurrentScript()
      meta.uri = script.src if script
      # NOTE: If the id-deriving methods above is failed, then falls back
      # to use onload event to get the uri

    # Emit `define` event, used in nocache plugin, seajs node version etc
    emit "define", meta

    # Save information for "saving" work in the script onload event
    if meta.uri?
      save meta.uri, meta
    else data.anonymousMeta = meta
    return

  # Save meta data to cachedMods
  @save: (uri, meta) ->
    {STATUS} = Module
    {get} = Module
    mod = get uri

    # Do NOT override already saved modules
    if mod.status < STATUS.SAVED
      mod.id = meta.id or uri
      mod.dependencies = meta.deps or []
      mod.factory = meta.factory
      mod.status = STATUS.SAVED
      emit "save", mod
    return

  # Get an existed module or create a new one
  @get: (uri, deps) ->
    data = getData()
    {cachedMods} = data
    cachedMods[uri] or cachedMods[uri] = new Module uri, deps

  # Use function is equal to load a anonymous module
  @use: (ids, callback, uri) ->
    data = getData()
    {cachedMods} = data
    {get} = Module

    mod = get uri, if isArray ids then ids else [ids]  # make sure typeof ids is array

    mod.callback = ->
      exports = []
      uris = mod.resolve()
      for uri in uris
        exports.push cachedMods[uri].exec()
      callback.apply global, exports if callback?
      delete mod.callback

    mod.load()
    return

  @define.cmd = {}

module.exports = Module
