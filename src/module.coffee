#
# module.js
#   - The core of module loader
#
getdata = -> seajs.data
utilLang = require './util-lang'
{isFunction} = utilLang

class Module

  constructor: (@uri, @deps = []) ->
    @status = 0
    @factory = null
    @exports = null
    @callback = null

    @sendRequest = null
    @fetched = false
    return @

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
  @STATUS:
    FETCHING: 1
    SAVED: 2
    LOADING: 3
    LOADED: 4
    EXECUTING: 5
    EXECUTED: 6

  # Load module.dependencies and fire onload when all done
  load: =>
    mod = @
    {STATUS} = Module

    # make sure mod fetched
    if mod.status < STATUS.FETCHING
      do mod.fetch

    # If the module is being loaded, just wait it onload call
    return if mod.status >= STATUS.LOADING
    mod.status = STATUS.LOADING

    return

  # Fetch a module
  fetch: =>
    mod = @
    {STATUS} = Module
    data = do getdata
    {addDeps} = data
    {fetchList} = data

    return if mod.status >= STATUS.FETCHING
    mod.status = STATUS.FETCHING

    {setFetchingNow} = data
    setFetchingNow mod.uri
    fetchList.push uri

    onRequest = ->
      data = do getdata
      fetchingNow = do data.getFetchingNow
      {id2uri} = seajs
      {get} = Module

      mod = get fetchingNow

      if mod.deps?

        addDeps mod.uri, mod.deps

        for id in mod.deps
          m = get id2uri id
          m.load()

      return

    {uri} = mod
    {charset} = data.getconfig()
    request uri, onRequest, charset

    do mod.onload if mod.callback?

    return

  # Call this method when module is loaded
  onload: =>
    mod = @

    mod.status = STATUS.LOADED
    mod.callback() if mod.callback?

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

    require = (id) -> get(require.resolve id).exec()
    require.resolve = (id) -> resolve id, uri
    require.async = (ids, callback) ->
      data = do getdata
      {cid} = data
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

    exports

  # Get an existed module or create a new one
  @get: (uri) ->
    data = do getdata
    {cachedMods} = data
    cachedMods[uri] or cachedMods[uri] = new Module uri

  @load: (uris, callback) ->
    data = do getdata
    {addDeps} = data
    {cachedMods} = data

    return unless uris?

    # load
    for uri in uris
      addDeps uri
      mod = Module.get uri
      mod.load()

    # exec
    exports = []
    for uri in uris
      m = cachedMods[uri]
      exp = m.exec()
      exports.push exp

    # callback
    callback.apply global if callback?

    return

module.exports = Module
