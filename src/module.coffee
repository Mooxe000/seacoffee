#
# module.js
#   - The core of module loader
#
utilLang = require './util-lang'
{isFunction} = utilLang
{isArray} = utilLang
{isString} = utilLang

getdata = -> do seajs.getdata

class Module

  constructor: (@uri, @deps = []) ->
    @status = 0
    @factory = null
    @exports = null
    return @

  @STATUS:
    FETCHING: 1
    FETCHED: 2
    LOADING: 3
    LOADED: 4
    EXECUTING: 5
    EXECUTED: 6

  # Load module.dependencies and fire onload when all done
  load: =>
    mod = @

    {STATUS} = Module

    # If the module is being loaded, just wait it onload call
    return if mod.status >= STATUS.LOADING

    # make sure mod fetched
    if mod.status < STATUS.FETCHING
      do mod.fetch

    mod.status = STATUS.LOADING
    emit 'load', mod.uri

    data = do getdata
    {events} = data
    {log} = events
    log.push load: mod.uri

    return

  # Fetch a module
  fetch: =>
    mod = @

    {STATUS} = Module

    data = do getdata
    {setLastFetch} = data
    {events} = data
    {log} = events

    return if mod.status >= STATUS.FETCHING
    mod.status = STATUS.FETCHING
    emit 'fetch', mod.uri
    log.push fetch: mod.uri
    setLastFetch mod.uri

    onRequest = ->
      do mod.onload
      return

    {uri} = mod
    {charset} = data.getconfig()
    emit 'request', mod.uri
    request uri, onRequest, charset

    return

  # Call this method when module is loaded
  onload: =>
    mod = @

    #
    # status
    #
    {STATUS} = Module
    mod.status = STATUS.LOADED

    #
    # callback
    #
    data = do getdata
    {getDepsList} = data
    {getDepsListFlat} = data
    depsroot = do ->
      depsObj = getDepsList mod.uri
      return depsObj if isString depsObj
      keys = Object.keys depsObj
      if isArray(keys) and keys.length is 1
        return keys[0]
    depsarry = getDepsListFlat mod.uri

    uris = null
    callback = null
    for _callback in data.callbacks
      continue if _callback.execed is true
      _uris = _callback.uris
      if _uris.indexOf depsroot isnt -1
        uris = _uris
        callback = _callback.callback

    {cachedMods} = data
    count = 0
    for uri in depsarry
      if not cachedMods[uri]? or cachedMods[uri].status < STATUS.LOADED
        m = get uri
        do m.load
        break
      else
        count++

    do callback if count is depsarry.length

    return

  # Execute a module
  exec: =>
    mod = @

    {STATUS} = Module
    {get} = Module

    {id2uri} = seajs

    # When module is executed, DO NOT execute it again. When module
    # is being executed, just return `module.exports` too, for avoiding
    # circularly calling
    return mod.exports if mod.status >= STATUS.EXECUTING
    mod.status = STATUS.EXECUTING

    # Create require
    require = (id) -> get(id2uri id).exec()
    require.resolve = (id) -> id2uri id
    require.async = (ids, callback) ->
      seajs.use ids, callback
      require

    # Exec factory
    {factory} = mod
    exports = if isFunction factory then factory require, mod.exports = {}, mod else factory
    exports = mod.exports unless exports?

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

    class Callback
      constructor: (@uris, callback) ->
        @execed = false
        @callback = =>
          # exec
          exports = []
          for uri in uris
            m = cachedMods[uri]
            exp = m.exec()
            exports.push exp

          @execed = true
          # callback
          callback.apply global, exports if callback?

    data.callbacks.push new Callback uris, callback

    {STATUS} = Module
    # load
    for uri in uris
      addDeps uri
      mod = Module.get uri
      if mod.status < STATUS.LOADED
        do mod.load
      else
        do mod.onload

    return

module.exports = Module
