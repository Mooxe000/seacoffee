seajs.config
  map: [
    ['/map/a.js', '/map/sub/a.js']

    [/^(.+\/)b\.js(.*)$/, '$1sub/b.js$2']

    [/^(.+\/)c\.js(.*)$/, (m, m1, m2) ->
      "#{m2}sub/c.js#{m2}"
    ]

    (url) ->
      if url.indexOf('d.js') > 0
        url = url.replace '/d.js', '/sub/d.js'
      url

    ['/debug/a.js', '/debug/a-debug.js']

    (url) ->
      if url.indexOf('/map/timestamp/') > 0
        "#{url}?t=20130202"
  ]