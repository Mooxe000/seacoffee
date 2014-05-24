alias =
  'a': 'config/alias/path/to/a'
  'biz/b': 'config/alias/path/to/biz/b'
  'c': 'config/alias/path/to/c.js'

seajs.config
  alias: alias

define (require) ->

  describe 'config', ->

    it 'alias', ->

      a = require 'a'
      b = require 'biz/b'
      c = require 'c'

      a.name.should.equal 'a'
      b.name.should.equal 'b'
      c.name.should.equal 'c'

# TODO
# require.async