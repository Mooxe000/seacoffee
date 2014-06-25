alias =
  'config_alias': 'config/alias/main'

seajs.config
  alias: alias

seajs.use 'config_alias', -> mocha.run()