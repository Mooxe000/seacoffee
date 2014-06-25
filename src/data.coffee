utilPath = require './util-path'
{cwd} = utilPath
{getLoaderDir} = utilPath
utilLang = require './util-lang'
{isArray} = utilLang
utilDeps = require './util-deps'
{findindeps} = utilDeps
Config = require './config'

class Data
  # _cid
  _cid = 0
  cid: => _cid++
  getcid: => _cid

  # The loader direcory
  dir = getLoaderDir()
  getdir: => dir

  # The current working directory
  cwd = cwd()
  getcwd: => cwd

  # config Data
  config = new Config
  getconfig: => config
  setconfig: (configData) => Config.config configData

  # fetchingnow
  fetchingNow = null
  getFetchingNow: => fetchingNow
  setFetchingNow: (fetching) => fetchingNow = fetching

  cachedMods: {}
  events: {}

  fetchList: []
  loadList: []

  # deps
  depsList = []
  getDepsList: => depsList
  addDeps: (uri, deps) =>
    unless deps?
      depsList.push uri
    else
      return unless isArray deps
      _r = findindeps(uri, depsList)
      return if _r is -1
      unless isArray _r
        deps.push uri
      else
        rep = depsList
        for pot in _r
          unless _i is _r.length - 1
            rep = rep[pot]
          else
            rep[pot] = {}
            rep[pot][uri] = deps
    return

module.exports = Data
