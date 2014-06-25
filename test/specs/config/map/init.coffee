alias =
  'config_map': 'config/map/main'

seajs.config
  alias: alias

seajs.use 'config_map', -> mocha.run()