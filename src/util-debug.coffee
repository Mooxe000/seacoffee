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

obj2json = (obj) ->
  JSON.stringify obj, null, 2

exports.obj2json = obj2json
