utilPath = require './util-path'
{cwd} = utilPath
{getLoaderDir} = utilPath
utilLang = require './util-lang'
{isArray} = utilLang
{isString} = utilLang
{isObject} = utilLang
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
  lastFetch = null
  getLastFetch: => lastFetch
  setLastFetch: (fatchuri) => lastFetch = fatchuri

  # currentNode
  currentlyAddingScript = null
  interactiveScript = null

  cachedMods: {}
  events: {
    log: []
  }

  # deps
  depsList = []
  depsListFlat = []

  fdinDpLs = (uri) ->
    return unless uri?
    return unless isString uri
    _r = findindeps uri, depsList
    return _r if isArray _r

  fdinDpLsFt = (uri) ->
    return unless uri?
    return unless isString uri
    for uris in depsListFlat
      if isString uris
        return _i if uris is uri
      else if isArray(uris) and uris.length isnt 0
        for _uri in uris
          return _i if _uri is uri
      else return

  addDeps: (uri, deps) =>
    return unless uri?
    return unless isString uri
    unless deps?
      # make sure uri not added
      for _uri in depsList
        return if _uri is uri
      # add to two cache list
      depsList.push uri
      depsListFlat.push new Array uri
    else
      # make sure deps are array
      return unless isArray deps
      # add to depsList
      atList = ->
        r = fdinDpLs uri
        return unless r?
        return unless isArray r
        rep = depsList
        for pot in r
          unless _j is r.length - 1
            rep = rep[pot]
          else
            rep[pot] = {}
            rep[pot][uri] = deps
        return
      do atList
      # add to depsListFlat
      atListFt = ->
        num = fdinDpLsFt uri
        depsListFlat.push uri unless num?
        return unless depsListFlat[num]?
        r = depsListFlat[num]
        _deps = deps.slice 0
        if isString r
          _deps.push r if _deps.indexOf r is -1
          depsListFlat[num] = _deps
        else if isArray r
          for _uri in deps
            r.push _uri if r.indexOf _uri is -1
        else return
      do atListFt
    return

  getDepsList: (uri) =>
    return depsList unless uri?
    r = fdinDpLs uri
    return depsList[r[0]] if depsList[r[0]]?

  getDepsListFlat: (uri) =>
    return depsListFlat unless uri?
    r = fdinDpLsFt uri
    return depsListFlat[r] if depsListFlat[r]?

  # callback
  callbacks: []

module.exports = Data
