#
# util-deps.js - The parser for dependencies
# ref: tests/research/parse-dependencies/test.html
# ref: https://github.com/seajs/searequire
#
utilLang = require './util-lang'
{isArray} = utilLang
{isObject} = utilLang
{isString} = utilLang

parseDependencies = (s) ->
  return [] if s.indexOf('require') is -1

  index = 0
  length = s.length
  isReg = 1
  modName = 0
  parentheseState = 0
  parentheseStack = []
  res = []

  peek = null

  readch = -> peek = s.charAt index++
  isBlank = -> /\s/.test peek
  isQuote = -> peek is '"' || peek is "'"
  dealQuote = ->
    start = index
    c = peek
    end = s.indexOf c, start
    if s.charAt(end - 1) isnt '\\'
      index = end + 1
    else
      while index < length
        do readch
        if peek is '\\'
          index++
        else if peek is c
          break
    if modName
      res.push s.slice start, index - 1
      modName = 0
  dealReg = ->
    index--
    while index < length
      do readch
      if peek is '\\'
        index++
      else if peek is '/'
        break
      else if peek is '['
        while index < length
          do readch
          if peek is '\\'
            index++
          else if peek is ']'
            break
  isWord = -> /[a-z_$]/i.test peek
  dealWord = ->
    s2 = s.slice index - 1
    r = /^[\w$]+/.exec(s2)[0]
    parentheseState = {
      'if': 1,
      'for': 1,
      'while': 1,
      'with': 1
    }[r]
    isReg = {
      'break': 1,
      'case': 1,
      'continue': 1,
      'debugger': 1,
      'delete': 1,
      'do': 1,
      'else': 1,
      'false': 1,
      'if': 1,
      'in': 1,
      'instanceof': 1,
      'return': 1,
      'typeof': 1,
      'void': 1
    }[r]
    modName = /^require\s*\(\s*(['"]).+?\1\s*\)/.test s2
    if modName
      r = /^require\s*\(\s*['"]/.exec(s2)[0]
      index += r.length - 2
    else
      index += /^[\w$.\s]+/.exec(s2)[0].length - 1
  isNumber = ->
    /\d/.test peek ||
      peek == '.' &&
        /\d/.test s.charAt index
  dealNumber = ->
    s2 = s.slice index - 1
    r = null
    if peek is '.'
      r = /^\.\d+(?:E[+-]?\d*)?\s*/i.exec(s2)[0]
    else if /^0x[\da-f]*/i.test(s2)
      r = /^0x[\da-f]*\s*/i.exec(s2)[0]
    else
      r = /^\d+\.?\d*(?:E[+-]?\d*)?\s*/i.exec(s2)[0]
    index += r.length - 1
    isReg = 0

  while index < length
    do readch
    if do isBlank
      continue
    else if do isQuote
      do dealQuote
      isReg = true
    else if peek is '/'
      do readch
      if peek is '/'
        index = s.indexOf '\n', index
        index = s.length if index is -1
        isReg = 1
      else if peek is '*'
        index = s.indexOf('*/', index) + 2
        isReg = 1
      else if isReg
        do dealReg
        isReg = 0
      else
        index--
        isReg = 1
    else if do isWord
      do dealWord
    else if do isNumber
      do dealNumber
    else if peek is '('
      parentheseStack.push(parentheseState)
      isReg = 1
    else if peek is ')'
      isReg = do parentheseStack.pop
    else
      isReg = peek != ']'
      modName = 0

  res

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

exports.parseDependencies = parseDependencies
exports.findindeps = findindeps
