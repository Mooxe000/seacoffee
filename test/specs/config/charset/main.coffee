seajs.config
  base: '/config/charset'
  alias:
    a: 'a'
    b: 'b'
  charset: (url) ->
    if url.indexOf('a.js') > 0
      return 'gbk'
    'utf-8'

define (require) ->

  describe 'config_charset', =>

    it 'check charset', =>

      a = require 'a'
      b = require 'b'

      a.message.should.equal '浣犲ソ GBK'
      b.message.should.equal '你好 UTF-8'

      return
    return
  return
