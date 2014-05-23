seajs = {}
#
# Api For Developers
#
utilLang = require './util-lang'
utilEvents = require './util-events'
eventOn = utilEvents.on
eventOff = utilEvents.off
{emit} = utilEvents
utilDom = require './util-dom'
utilDeps = require './util-deps'
utilPath = require './util-path'
{id2Uri} = utilPath
utilRequest = require './util-request'
{request} = utilRequest
Module = require './module'
{get} = Module
{use} = Module
{resolve} = Module
{config} = Module
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

global.seajs = seajs
global.define = Module.define
