seajs.config
  base: '/config/base'

define (require) ->

  describe 'config_alias', =>

    it 'require', =>
      a = require 'a'
      b = require 'b'
      a.name.should.equal 'a'
      b.name.should.equal 'b'