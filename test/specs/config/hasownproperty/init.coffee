alias =
  'config_hasOwnProperty': 'config/hasownproperty/main'

seajs.config
  alias: alias

seajs.use 'config_hasOwnProperty', -> mocha.run()