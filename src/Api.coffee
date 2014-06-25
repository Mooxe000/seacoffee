#
# Api For Developers
#
# utilLang = require './util-lang'
utilEvents = require './util-events'
eventOn = utilEvents.on
eventOff = utilEvents.off
{emit} = utilEvents
utilRequest = require './util-request'
{request} = utilRequest
# utilDom = require './util-dom'
#utilDeps = require './util-deps'
utilDebug = require './util-debug'
{prtConf} = utilDebug
{prtData} = utilDebug
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
seajs.Module = Module

seajs.id2uri = id2uri
seajs.request = request
# seajs.require = (id) ->

#
# Api For Public
#
seajs.version = "@VERSION" # The current version of Sea.js being used

seajs.data = new Data

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

global.prtConf = -> do prtConf
global.prtData = -> do prtData
