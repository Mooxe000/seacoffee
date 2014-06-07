seajs.config
  base: '/config/hasownproperty'
  alias:
    hasOwnProperty: 'hasOwnProperty'
    toString: 'toString'
    a: 'a'

define (require) ->

  describe 'config_charset', =>

    it 'a', =>

      a = require 'a'
      a.name.should.equal 'a'

      return

    it 'hasOwnProperty', =>

      hasOwnProperty = require 'hasownproperty'
      hasOwnProperty.name
      .should.equal 'hasOwnProperty'

      return

    it 'toString', =>

      toString = require 'toString'
      toString.name
      .should.equal 'toString'

      return

    return
  return
