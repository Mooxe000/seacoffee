#
# Api For Developers
#

seajs = {}

# utilLang = require './util-lang'
utilEvents = require './util-events'
eventOn = utilEvents.on
eventOff = utilEvents.off
{emit} = utilEvents
utilRequest = require './util-request'
{request} = utilRequest
# utilDom = require './util-dom'
# utilDeps = require './util-deps'
utilDebug = require './util-debug'
{obj2json} = utilDebug
Config = require './config'
{id2Uri} = Config
{config} = Config
Module = require './module'
{get} = Module
{use} = Module
{resolve} = Module
data = require './data'

seajs.cache = data.cachedMods
seajs.Module = Module
seajs.require = (id) ->
  mod = get resolve id
  if mod.status < Module.STATUS.EXECUTING
    mod.onload()
    mod.exec()
  mod.exports
seajs.resolve = id2Uri
seajs.request = request

#
# Api For Public
#
seajs.version = "@VERSION" # The current version of Sea.js being used

seajs.data = data
seajs.getData = -> seajs.data

seajs.config = (configData) ->
  config configData
  seajs
seajs.use = (ids, callback) ->
  use ids, callback, data.cwd + "_use_" + data.cid()
  seajs

seajs.on = (name, callback) ->
  eventOn name, callback
  seajs
seajs.off = (name, callback) ->
  eventOff name, callback
  seajs
seajs.emit = (name, data) ->
  emit name, data
  seajs

seajs.log = (obj) ->
  echo obj2json obj

global.seajs = seajs
global.define = Module.define

global.echo = console.log
