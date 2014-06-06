#
# util-request.js
#   - The utilities for requesting script and style filesl
# ref: tests/research/load-js-css/test.htm
#

utilLang = require './util-lang'
{isFunction} = utilLang
utilDom = require './util-dom'
{getBaseEle} = utilDom
{getHead} = utilDom
{createScript} = utilDom
utilEvents = require './util-events'
{emit} = utilEvents

currentlyAddingScript = null

request = (url, callback, charset) ->
  node = createScript()

  if charset?
    cs = if isFunction charset then charset url else charset
    node.charset = cs if cs?

  addOnload node, callback, url

  node.async = true
  node.src = url
  
  # For some cache cases in IE 6-8, the script executes IMMEDIATELY after
  # the end of the insert execution, so use `currentlyAddingScript` to
  # hold current node, for deriving url in `define` call
  currentlyAddingScript = node

  baseElement = getBaseEle()
  # ref: #185 & http://dev.jquery.com/ticket/2709
  head = getHead()
  if baseElement?
    head.insertBefore node, baseElement
  else head.appendChild node

  currentlyAddingScript = null
  return

addOnload = (node, callback, url) ->
  supportOnload = "onload" of node

  onload = ->
    # Ensure only run once and handle memory leak in IE
    node.onload = node.onerror = node.onreadystatechange = null

    # Remove the script to reduce memory leak
    head = getHead()
    head.removeChild node unless debug?

    # Dereference the node
    node = null
    callback()
    return

  if supportOnload?
    node.onload = onload
    node.onerror = ->
      emit "error",
        uri: url
        node: node
      onload()
      return
  else node.onreadystatechange = ->
    onload() if /loaded|complete/.test node.readyState
    return

exports.request = request
