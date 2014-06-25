alias =
  'config_charset': 'config/charset/main'

seajs.config
  alias: alias

seajs.use 'config_charset', -> mocha.run()