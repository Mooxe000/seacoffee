#
# util-dom.js
#   - The utilities for operate dom object
#
getDoc = -> document
getdata = -> seajs.data

getHead = ->
  doc = getDoc()
  doc.head or doc.getElementsByTagName("head")[0] or doc.documentElement

getScripts = ->
  doc = getDoc()
  doc.getElementsByTagName 'script'

getBaseEle = ->
  head = getHead()
  head.getElementsByTagName("base")[0]

createScript = ->
  doc = getDoc()
  doc.createElement 'script'

getCurrentScript = ->
  data = do getdata
  currentNode = do data.getCurrentNode
  return currentNode if currentNode?

  # For IE6-9 browsers, the script onload event may not fire right
  # after the script is evaluated. Kris Zyp found that it
  # could query the script nodes and the one that is in "interactive"
  # mode indicates the current script
  # ref: http://goo.gl/JHfFW
  return interactiveScript if interactiveScript? and interactiveScript.readyState is "interactive"

  scripts = getScripts()

  scripts = scripts.reverse()

  for script in scripts
    if script.readyState is "interactive"
      interactiveScript = script
      return interactiveScript

getScriptAbsoluteSrc = (node) ->
  if node.hasAttribute
    # non-IE6/7
    node.src
    # see http://msdn.microsoft.com/en-us/library/ms536429(VS.85).aspx
  else node.getAttribute "src", 4

getLoaderScript = ->
  doc = getDoc()
  scripts = getScripts()
  doc.getElementById('seajsnode') or scripts[scripts.length - 1]

getLoaderDir = ->
  loaderScript = do getLoaderScript
  data = do getdata
  cwd = do data.getcwd
  dirname getScriptAbsoluteSrc loaderScript || cwd

exports.getDoc = getDoc
exports.getHead = getHead
exports.getScripts = getScripts
exports.getBaseEle = getBaseEle
exports.createScript = createScript
exports.getLoaderScript = getLoaderScript
exports.getScriptAbsoluteSrc = getScriptAbsoluteSrc
exports.getCurrentScript = getCurrentScript
