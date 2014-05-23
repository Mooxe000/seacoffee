#
# util-deps.js
#   - The parser for dependencies
# ref: tests/research/parse-dependencies/test.html
#

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

exports.RE = RE
exports.parseDependencies = parseDependencies
