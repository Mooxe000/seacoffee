getdata = -> seajs.data
utilLang = require './util-lang'
{isArray} = utilLang
{isFunction} = utilLang
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

  {id2uri} = seajs

  # ------------
  # get deps
  #   - Parse dependencies according to the module factory code
  # ------------
  deps = parseDependencies factory.toString() if not isArray(deps) and isFunction factory
  _deps = []
  for dep in deps
    _deps.push id2uri dep
  # ------------

  data = do getdata
  fetchingNow = do data.getFetchingNow

  uri = id2uri id if id?
  uri = if uri is fetchingNow then uri else fetchingNow

  mod = Module.get uri

  mod.id = id
  mod.deps = _deps
  mod.factory = factory

  return

module.exports = define