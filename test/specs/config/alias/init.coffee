base = '/'

alias =
  'config_alias': 'config/alias/main'

seajs.config
  base: base
  alias: alias
  debug: true

seajs.use 'config_alias', -> mocha.run()