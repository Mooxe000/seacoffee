getdata = -> seajs.data
utilLang = require './util-lang'
{isArray} = utilLang
{isFunction} = utilLang
utilDom = require './util-dom'
{getCurrentScript} = utilDom
utilDeps = require './util-deps'
{parseDependencies} = utilDeps

# Define a module
define = (args...) ->
  # args
  argsLen = args.length
  switch argsLen
    when 1
      # define(factory)
      factory = args[0]
      id = null
      deps = null
    when 2
      factory = args[1]
      if isArray args[0]
        # define(deps, factory)
        deps = args[0]
        id = null
      else
        # define(id, factory)
        id = args[0]
        deps = null
    when 3
      # define(id, deps, factory)
      id = args[0]
      deps = args[1]
      factory = args[2]
    else return


  # ------------
  # get deps
  #   - Parse dependencies according to the module factory code
  # ------------
  _deps = parseDependencies factory.toString() if not isArray(deps) and isFunction factory
  {id2uri} = seajs

  _deps_ = []

  if isArray(deps) and deps.length > 0
    for dep in deps
      _deps_.push id2uri dep if _deps_.indexOf dep is -1
  if isArray(_deps) and _deps.length > 0
    for _dep in _deps
      _deps_.push id2uri _dep if _deps_.indexOf _dep is -1

  script = do getCurrentScript
  uri = script.src

  unless uri?
    data = do getdata
    lastfetch = do data.getLastFetch
    uri = id2uri id if id?
    uri = if uri is lastfetch then uri else fetchingNow

  mod = Module.get uri
  mod.deps = _deps_ if _deps_.length isnt 0
  mod.factory = factory

  if isArray(mod.deps) and mod.deps.length > 0
    {addDeps} = do getdata
    addDeps mod.uri, mod.deps

  return

module.exports = define