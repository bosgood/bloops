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
    @api.list()

show =
  filters: [FromUrlParams]
  handler :->
    @api.find(_id: @params.id)

update =
  filters: [FromJson]
  handler: ->
    @api.update(
      { _id: @params._id },
      @params
    )

destroy =
  filters: [FromJson, FromUrlParams]
  handler: ->
    @api.remove(_id: @params.id)
    .then((removedCount) =>
      if removedCount == 0
        return null
      else
        return {
          _id: @params.id
          deletedCount: removedCount
        }
    )

create =
  filters: [FromJson]
  handler: ->
    @context.statusCode = 201
    @api.create @params

patch =
  filters: [FromJson]
  handler: ->
    @api.update @params._id, @params

module.exports = {index, show, update, destroy, create, patch}