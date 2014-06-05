seajs.config
  base: '/config/base'
  alias:
    c: 'a'
    a: 'b'

define (require) ->

  describe 'config_base', =>

    it 'name is different', =>

      a = require 'c'
      a.name.should.equal 'a'

      return

    it 'name is not exist', =>

      b = require 'a'
      b.name.should.equal 'b'

      return

    it 'change base', =>

      d = require 'd'
      d.name.should.equal 'd'

      return

    return
  return
