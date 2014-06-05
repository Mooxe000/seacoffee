seajs.config
  base: '/config/charset'
  alias:
    a: 'a'
    b: 'b'

define (require) ->

  describe 'config_charset', =>

    it 'check charset', =>

      a = require 'a'
      b = require 'b'

      a.message.should.equal ''
