logData = ->
  dump JSON.stringify seajs.getData(), null, 2

base = '/absolute/Volumes/Macintosh%20HD%202%201/WORKSPACE/WEB/seajs/seacoffee/test/specs/'

alias =
  'config_alias': 'config/alias/main.js'
  'config_base': 'config/base/main.js'

seajs.config
  base: base
  alias: alias
  debug: true

describe 'seajs', ->

  it 'global', ->

    document.should.be.a 'object'
    seajs.should.be.a 'object'
    define.should.be.a 'function'
    define.cmd.should.be.a 'object'

window.__karma__.start = ->
  seajs.use [
    'config_alias'
#    'config_base'
  ], -> mocha.run()
