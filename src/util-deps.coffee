#
# util-deps.js
#   - The parser for dependencies
# ref: tests/research/parse-dependencies/test.html
#
utilLang = require './util-lang'
{isArray} = utilLang
{isObject} = utilLang
{isString} = utilLang

RE =
  REQUIRE: /"(?:\\"|[^"])*"|'(?:\\'|[^'])*'|\/\*[\S\s]*?\*\/|\/(?:\\\/|[^\/\r\n])+\/(?=[^\/])|\/\/.*|\.\s*require|(?:^|[^$])\brequire\s*\(\s*(["'])(.+?)\1\s*\)/g
  SLASH: /\\\\/g

# 分析源码，取出 依赖列表
parseDependencies = (code) ->
  ret = []
  code.replace(RE.SLASH, "").replace RE.REQUIRE, (m, m1, m2) ->
    ret.push m2 if m2
    return
  ret

###
[
  uri_0
  uri_1: [
    uri_2
    uri_3: [
      uri_4
      uri_5
    ]
  ]
]
# -----------------
[
  'a'
  {
    'b': [
      'c'
      'd'
    ]
  }
  {
    'e': [
      'f'
      {
        'aaa': [
          'abc'
          'def'
          '333'
        ]
      }
      '3'
      'G'
      '12'
      'H'
    ]
  }
]
###
findindeps = (uri, depsArr, stack = []) ->
  for _uri in depsArr
    if isString _uri
      if _uri is uri
        stack.push _i
        return stack
      else continue
    else if isObject _uri
      for k, v of _uri
        if k is uri
          stack.push _i
          return stack
        else if isArray v
          stack.push _i
          stack.push k
          _stack = stack.toString()
          stack = findindeps uri, depsArr[_i][k], stack
          if not _stack? or _stack is stack.toString()
            stack.pop()
            stack.pop()
            continue
          else
            return stack
  return stack

exports.RE = RE
exports.findindeps = findindeps
exports.parseDependencies = parseDependencies
