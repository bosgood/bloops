filters = require './filters'
FromJson = filters.FromJson
FromUrlParams = filters.FromUrlParams

###
Endpoint implementations

Endpoints are called in the context of an object with the following properties:
  response (alias: res) - current HTTP response
  request (alias: req) - current HTTP request
  parameters (alias: params) - parameters from the current request
###
index =
  filters: [FromUrlParams]
  handler: ->
    @api.find()
show =
  filters: [FromUrlParams]
  handler :->
    @api.find @params.id

update =
  filters: [FromJson]
  handler: ->
    @api.update @params.id, @params

destroy =
  filters: [FromUrlParams]
  handler: ->
    @api.remove @params.id

create =
  filters: [FromJson]
  handler: ->
    @context.statusCode = 201
    @api.create @params

patch =
  filters: [FromJson]
  handler: ->
    @api.update @params.id, @params

module.exports = {index, show, update, destroy, create, patch}