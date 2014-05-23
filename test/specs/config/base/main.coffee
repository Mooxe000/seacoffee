base = '/absolute/Volumes/Macintosh%20HD%202%201/WORKSPACE/WEB/seajs/seacoffee/test/specs/base'

alias =
  'a': 'config/base/a'

seajs.config
  base: base
  alias: alias

#define (require) ->
#
#  describe 'config', ->
#
#    it 'base', ->
#
#      a = require 'a'
#
#      a.name.should.equal 'a'