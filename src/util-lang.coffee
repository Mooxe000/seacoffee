#
# util-lang.js
#   - The minimal language enhancement
#

isType = (type) -> (obj) ->
  {}.toString.call(obj) is "[object #{type}]"

isObject = isType "Object"
isString = isType "String"
isArray = Array.isArray or isType "Array"
isFunction = isType "Function"

exports.isObject = isObject
exports.isString = isString
exports.isArray = isArray
exports.isFunction = isFunction
