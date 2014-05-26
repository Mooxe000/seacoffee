seajs.config
  base: '../base'

define (require) ->

  describe 'config_base', =>

    it 'require', =>
      a = require 'a'
      a.name.should.equal 'a'
      return