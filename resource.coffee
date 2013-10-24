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

  additionalEndpoints: null

  # Gets a list of all endpoints for this resource
  getEndpoints: ->
    endpoints = []
    for own endpoint of @crudEndpoints
      endpoints.push(endpoint)
    if @additionalEndpoints?
      additionalEndpoints = if typeof @additionalEndpoints == 'function' then @additionalEndpoints() else @additionalEndpoints
      for endpoint of moreEndpoints
        endpoint = endpoint() if
        endpoints.push(endpoint)
    endpoints

  # Adds this resource's endpoints to an HTTP application router
  initializeResource: (app) ->
    for endpoint in @getEndpoints()
      if typeof endpoint == 'string'
        endpoint = @crudEndpoints[endpoint]
        if not endpoint?
          throw new Error(
            'must provide valid endpoint or name of existing endpoint'
          )
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
        api: @adapter
        model: @model
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
        returnObj = e

      @syncResponse(
        @getResponseReplier(res),
        customContext,
        returnObj,
        isError=true
      )

  # Override to send something other than or in addition to, a JSON body
  getResponseReplier: (res) ->
    (args...) ->
      res.json.apply(res, args)

  isPromise: (obj) ->
    typeof returnObj == 'function' and obj.then?

  # Normalizes handling of synchronous and asynchronous responses
  syncResponse: (reply, customContext, returnObj, isError = false) ->
    doReply = (_returnValue, _isError) ->
      responseObj = @convertToResponse(
        customContext.statusCode, _returnValue, _isError
      )
      reply(responseObj.statusCode, responseObj.body)

    if not @isPromise(returnObj)
      doReply(returnObj, isError)
    else
      returnObj
      .then((result) ->
        doReply(result, false)
      )
      .fail((error) ->
        doReply(error, true)
      )
      .done()

  # Creates an object suitable for use with paged UIs
  createDataPage: (dataArray, offset = 0, limit = -1) ->
    return {
      totalCount: dataArray.length
      count: dataArray.length
      offset: offset
      limit: limit
      objects: dataArray
    }

  # Creates a response code and response body from a method return value
  convertToResponse: (statusCode = 200, retObj, isError = false) ->
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
    @api.find()

  showFilters: [FromUrlParams]
  show: ->
    @api.find @params.id

  updateFilters: [FromJson]
  update: ->
    @api.update @params.id, @params

  destroyFilters: [FromUrlParams]
  destroy: ->
    @api.remove @params.id

  createFilters: [FromJson]
  create: ->
    @context.statusCode = 201
    @api.create @params

  patchFilters: [FromJson]
  patch: ->
    @api.update @params.id, @params