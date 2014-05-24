alias =
  'a': 'config/alias/path/to/a'
  'biz/b': 'config/alias/path/to/biz/b'

seajs.config
  alias: alias

define (require) ->

  describe 'config', ->

    it 'alias', ->

      a = require 'a'
      b = require 'biz/b'
      a.name.should.equal 'a'
      b.name.should.equal 'b'

      alias =
        'a': 'x'
        'c': 'config/alias/path/to/c.js'

      seajs.config
        alias: alias

      c = seajs.require 'c'
      c.name.should.equal 'c'

# TODO
# require.async