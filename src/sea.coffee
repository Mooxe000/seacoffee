#
# Seajs && Api
#

# utilLang = require './util-lang'

utilEvents = require './util-events'
eventOn = utilEvents.on
eventOff = utilEvents.off
{emit} = utilEvents

utilRequest = require './util-request'
{request} = utilRequest

# utilDom = require './util-dom'
# utilDeps = require './util-deps'

{config} = require './config'
id2uri = require './config.id2uri'

Module = require './module'
{get} = Module
{load} = Module
{save} = Module

define = require './module.define'
use = require './module.use'

Data = require './data'

seajs = {}
seajs.version = "@VERSION" # The current version of Sea.js being used

seajs.data = new Data
seajs.getdata = -> seajs.data

seajs.config = (configData) ->
  config configData
  seajs

seajs.use = (ids, callback) ->
  use ids, callback
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
global.define = define
global.define.cmd = {}

seajs.Module = Module
seajs.id2uri = id2uri
seajs.request = request
# seajs.require = (id) ->

#
# Debug Tools
#
utilDebug = require './util-debug'

{echoConf} = utilDebug
{echoDeps} = utilDebug
{echoDepsFlat} = utilDebug
{echoEventLog} = utilDebug
{echoLastFetch} = utilDebug
{echoCurrentNode} = utilDebug

global.echoConf = -> do echoConf
global.echoDeps = -> do echoDeps
global.echoDepsFlat = -> do echoDepsFlat
global.echoEventLog = -> do echoEventLog
global.echoLastFetch = -> do echoLastFetch
global.echoCurrentNode = -> do echoCurrentNode
