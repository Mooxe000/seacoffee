#!/usr/bin/env coffee
#echo = console.log
should = require('chai').should()
foo = 'bar'
beverages =
  tea: [
    'chai'
    'matcha'
    'oolong'
  ]

describe 'chai', ->
  it 'chai', ->
    foo.should.be.a 'string'
    foo.should.equal 'bar'
    foo.should.have.length 3
    beverages.should.have.property('tea').with.length 3