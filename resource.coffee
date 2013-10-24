filters = require './filters'
FromJson = filters.FromJson
FromUrlParams = filters.FromUrlParams

# Defines a RESTful resource accessible through an HTTP API
class HttpResource
  # Define as an (sub)type of DataAdapter
  adapter: null
  # Define as a type your DataAdapter will understand
  model: null

  crudEndpoints:
    index:
      route: '/'
      method: 'GET'
      handler: @index
      filters: @indexFilters
      emptyResult: []

    show:
      route: '/:id'
      method: 'GET'
      handler: @show
      filters: @showFilters

    update:
      route: '/:id'
      method: 'PUT'
      handler: @update
      filters: @updateFilters

    destroy:
      route: '/:id'
      method: 'DELETE'
      handler: @destroy
      filters: @destroyFilters

    create:
      route: '/'
      method: 'POST'
      handler: @create
      filters: @createFilters

    patch:
      route: '/:id'
      method: 'PATCH'
      handler: @patch
      filters: @patchFilters

  # Gets a list of all endpoints for this resource
  getEndpoints: ->
    endpoints = []
    for own endpoint of @crudEndpoints
      endpoints.push(endpoint)
    endpoints

  # Adds this resource's endpoints to an HTTP application router
  initializeResource: (app) ->
    for endpoint in @getEndpoints()
      handler = @createHandler(endpoint.handler)
      @addEndpoint(app, endpoint, handler)

  # Implement this in a subclass to add a given endpoint to an HTTP app
  addEndpoint: (app) ->

  # Binds route handlers to a context to make their definitions easier
  createHandler: (handler, paramFilters) ->
    (req, res) ->
      params = paramFilters.reduce (params, filter) ->
        filter.process(req, res, params)
      , {}

      customContext =
        responseCode: null

      context =
        request: req
        req: req
        response: res
        res: res
        parameters: params
        params: params
        context: customContext

      try
        returnObj = handler.call(context)
      catch e
        errorObj = e

      # Transform a return value from a method into an HTTP status code
      # and JSON response body
      responseObj = @processReturnObject(
        customContext.statusCode, returnObj, errorObj
      )
      res.json(responseObj.statusCode, responseObj.body)

  # Creates an object suitable for use with paged UIs
  createDataPage: (dataArray, offset = 0, limit = -1) ->
    return {
      totalCount: dataArray.length
      count: dataArray.length
      offset: offset
      limit: limit
      objects: dataArray
    }

  processReturnObject: (statusCode = 200, retObj, errorObj) ->
    if not errorObj
      statusCode = statusCode
      unless Array.isArray(retObj)
        body = retObj
      else
        body = @createDataPage(retObj)

    else
      # Got an error, force an error status code if not provided one
      statusCode = if statusCode < 400 then 500 else statusCode
      body = errorObj.data or {}
      body.error: errorObj.message or 'an error occurred'

    {statusCode, body}

  ###
  Endpoint implementations

  Endpoints are called in the context of an object with the following properties:
    response (alias: res) - current HTTP response
    request (alias: req) - current HTTP request
    parameters (alias: params) - parameters from the current request
  ###

  indexFilters: [FromUrlParams]
  index: ->

  showFilters: [FromUrlParams]
  show: ->

  updateFilters: [FromJson]
  update: ->

  destroyFilters: [FromUrlParams]
  destroy: ->

  createFilters: [FromJson]
  create: ->

  patchFilters: [FromJson]
  patch: ->