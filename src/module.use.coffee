utilLang = require './util-lang'
{isArray} = utilLang
Module = require './module'

# Use function is equal to load a anonymous module
use = (ids, callback) ->

  # make sure typeof ids must be array
  ids = if isArray ids then ids else [ids]

  # get uris
  uris = []
  for id in ids
    uris.push id2uri id

  Module.load uris, callback

  seajs

module.exports = use
