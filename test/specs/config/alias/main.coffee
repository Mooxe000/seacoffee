alias =
  'a': 'config/alias/path/to/a'
  'biz/b': 'config/alias/path/to/biz/b'

seajs.config
  alias: alias

define (require) ->

  describe 'config_alias', =>

    it 'require', =>
      a = require 'a'
      b = require 'biz/b'
      a.name.should.equal 'a'
      b.name.should.equal 'b'

      alias =
        'a': 'x'
        'c': 'config/alias/path/to/c.js'

      seajs.config
        alias: alias

      return

    it 'require_async', (done) =>
      require.async 'c', (c) ->
        c.name.should.equal 'c'
        done()
        return
      return

    it 'require_promised', (done) =>
      requireC = ->
        deferred = Q.defer()
        require.async 'c', (c) ->
          deferred.resolve c.name
        deferred.promise

      promise = requireC()
      promise
      .should.eventually
      .equal 'c'
      .notify done
