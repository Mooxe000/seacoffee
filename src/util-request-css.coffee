###
  util-request.js
    - The utilities for requesting script and style files
  ref: tests/research/load-js-css/test.html
###

# `onload` event is not supported in WebKit < 535.23 and Firefox < 9.0
# ref:
#  - https://bugs.webkit.org/show_activity.cgi?id=38995
#  - https://bugzilla.mozilla.org/show_bug.cgi?id=185236
#  - https://developer.mozilla.org/en/HTML/Element/link#Stylesheet_load_events
request = (url, callback, charset) ->
  isCSS = IS_CSS_RE.test(url)
  node = doc.createElement((if isCSS then "link" else "script"))
  if charset
    cs = (if isFunction(charset) then charset(url) else charset)
    node.charset = cs  if cs
  addOnload node, callback, isCSS, url
  if isCSS
    node.rel = "stylesheet"
    node.href = url
  else
    node.async = true
    node.src = url
  
  # For some cache cases in IE 6-8, the script executes IMMEDIATELY after
  # the end of the insert execution, so use `currentlyAddingScript` to
  # hold current node, for deriving url in `define` call
  currentlyAddingScript = node
  
  # ref: #185 & http://dev.jquery.com/ticket/2709
  (if baseElement then head.insertBefore(node, baseElement) else head.appendChild(node))
  currentlyAddingScript = null
  return
addOnload = (node, callback, isCSS, url) ->
  
  # for Old WebKit and Old Firefox
  # Begin after node insertion
  onload = ->
    
    # Ensure only run once and handle memory leak in IE
    node.onload = node.onerror = node.onreadystatechange = null
    
    # Remove the script to reduce memory leak
    head.removeChild node  if not isCSS and not data.debug
    
    # Dereference the node
    node = null
    callback()
    return
  supportOnload = "onload" of node
  if isCSS and (isOldWebKit or not supportOnload)
    setTimeout (->
      pollCss node, callback
      return
    ), 1
    return
  if supportOnload
    node.onload = onload
    node.onerror = ->
      emit "error",
        uri: url
        node: node

      onload()
      return
  else
    node.onreadystatechange = ->
      onload()  if /loaded|complete/.test(node.readyState)
      return
  return
pollCss = (node, callback) ->
  sheet = node.sheet
  isLoaded = undefined
  
  # for WebKit < 536
  if isOldWebKit
    isLoaded = true  if sheet
  
  # for Firefox < 9.0
  else if sheet
    try
      isLoaded = true  if sheet.cssRules
    catch ex
      
      # The value of `ex.name` is changed from "NS_ERROR_DOM_SECURITY_ERR"
      # to "SecurityError" since Firefox 13.0. But Firefox is less than 9.0
      # in here, So it is ok to just rely on "NS_ERROR_DOM_SECURITY_ERR"
      isLoaded = true  if ex.name is "NS_ERROR_DOM_SECURITY_ERR"
  setTimeout (->
    if isLoaded
      
      # Place callback here to give time for style rendering
      callback()
    else
      pollCss node, callback
    return
  ), 20
  return
getCurrentScript = ->
  return currentlyAddingScript  if currentlyAddingScript
  
  # For IE6-9 browsers, the script onload event may not fire right
  # after the script is evaluated. Kris Zyp found that it
  # could query the script nodes and the one that is in "interactive"
  # mode indicates the current script
  # ref: http://goo.gl/JHfFW
  return interactiveScript  if interactiveScript and interactiveScript.readyState is "interactive"
  scripts = head.getElementsByTagName("script")
  i = scripts.length - 1

  while i >= 0
    script = scripts[i]
    if script.readyState is "interactive"
      interactiveScript = script
      return interactiveScript
    i--
  return
head = doc.head or doc.getElementsByTagName("head")[0] or doc.documentElement
baseElement = head.getElementsByTagName("base")[0]
IS_CSS_RE = /\.css(?:\?|$)/i
currentlyAddingScript = undefined
interactiveScript = undefined
isOldWebKit = +navigator.userAgent.replace(/.*(?:AppleWebKit|AndroidWebKit)\/(\d+).*/, "$1") < 536

# For Developers
seajs.request = request
