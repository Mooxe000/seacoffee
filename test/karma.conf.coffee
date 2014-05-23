# Karma configuration
# Generated on Sun May 18 2014 15:46:44 GMT+0800 (CST)

module.exports = (config) ->
  config.set

    # base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: './specs'

    # frameworks to use
    # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [
      'mocha'
      'chai'
    ]

    # preprocess matching files before serving them to the browser
    # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors:
      './../*.coffee': ['coffee']
      '**/*.coffee': ['coffee']

    # list of files / patterns to load in the browser
    files: [
      './../../dist/sea-debug.js'
      './../main.coffee'
      {
        pattern: './**/*.coffee'
        included: false
      }
    ]

    # list of files to exclude
    exclude: [

    ]

    coffeePreprocessor:
      # options passed to the coffee compiler
      options:
        bare: true
        sourceMap: false

      # transforming the filenames
      transformPath: (path) ->
        path.replace /\.coffee$/, '.js'

    # test results reporter to use
    # possible values: 'dots', 'progress'
    # vailable reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: [
      'progress'
#      'mocha'
      'spec'
    ]

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # start these browsers
    # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS']

    # Continuous Integration mode
    # if true, Karma captures browsers, runs the tests and exits
    singleRun: false

    # load the needed plugins (according to karma docs, this should not be needed tho)
    plugins: [
      'karma-mocha'
      'karma-mocha-reporter'
      'karma-spec-reporter'
      'karma-chai'
      'karma-phantomjs-launcher'
      'karma-coffee-preprocessor'
      'karma-jade-preprocessor'
    ]