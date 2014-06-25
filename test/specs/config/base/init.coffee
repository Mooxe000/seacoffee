alias =
  'config_base': 'config/base/main'

seajs.config
  alias: alias

seajs.use 'config_base', -> mocha.run()