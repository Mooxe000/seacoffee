#
# Debug Tool
#   - for debug
#

## 遍历属性
## http://www.cnblogs.com/ziyunfei/archive/2012/11/03/2752905.html
#getKeys = (obj) ->
#  Object.keys obj
#
#getOwnPropertyNames = (obj) ->
#  Object.getOwnPropertyNames obj
#
#getEnumPropertyNames = (obj) ->
#  props = []
#  for prop in obj
#    props.push prop
#  props
#
#getAllPropertyNames = (obj) ->
#  props = []
#  ownPropertyName = getOwnPropertyNames obj
#  props = props.concat ownPropertyName while obj = Object.getPrototypeOf obj
#
## http://www.cnblogs.com/ziyunfei/archive/2012/11/12/2765794.html
## 遍历原型链
#getPrototypeChain = (obj) ->
#  protoChain = []
#  protoChain.push obj while obj = Object.getPrototypeOf obj
#  protoChain.push null
#  protoChain
#
## 遍历调用栈
#getCallStack = ->
#  stack = []
#  fun = getCallStack
#  stack.push fun while fun = fun.caller
#  stack

echo = (msg) -> console.log msg
obj2json = (obj) -> JSON.stringify obj, null, 2

echoConf = -> echo obj2json do seajs.data.getconfig
echoDeps = -> echo obj2json do seajs.data.getDepsList
echoDepsFlat = -> echo obj2json do seajs.data.getDepsListFlat
echoEventLog = -> echo obj2json seajs.data.events.log
echoLastFetch = -> echo obj2json do seajs.data.getLastFetch
echoCurrentNode = -> echo do seajs.data.getCurrentNode

exports.echoConf = echoConf
exports.echoDeps = echoDeps
exports.echoDepsFlat = echoDepsFlat
exports.echoEventLog = echoEventLog
exports.echoLastFetch = echoLastFetch
exports.echoCurrentNode = echoCurrentNode