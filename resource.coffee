filters = require './filters'
FromJson = filters.FromJson
FromUrlParams = filters.FromUrlParams
crud = require './crud'

# Defines a RESTful resource accessible through an HTTP API
class HttpResource
  # Define as an (sub)type of DataAdapter
  adapter: null
  # Define as a type your DataAdapter will understand
  model: null
  # If defined, will be prepended to all routes
  resourceName: null
  additionalEndpoints: null
  crudEndpoints:
    index:
      route: '/'
      method: 'GET'
      handler: crud.index.handler
      filters: crud.index.filters

    show:
      route: '/:id'
      method: 'GET'
      handler: crud.show.handler
      filters: crud.show.filters

    update:
      route: '/:id'
      method: 'PUT'
      handler: crud.update.handler
      filters: crud.update.filters

    destroy:
      route: '/:id'
      method: 'DELETE'
      handler: crud.destroy.handler
      filters: crud.destroy.filters

    create:
      route: '/'
      method: ['POST', 'PUT']
      handler: crud.create.handler
      filters: crud.create.filters

    patch:
      route: '/:id'
      method: 'PATCH'
      handler: crud.patch.handler
      filters: crud.patch.filters

  constructor: (options) ->
    for own option, val of options
      # console.log "[RESOURCE] setting option: #{option}"
      @[option] = val

  # Gets a list of all endpoints for this resource
  getEndpoints: -> [
    'index'
    'show'
    'update'
    'destroy'
    'create'
    'patch'
  ]

  # Adds this resource's endpoints to an HTTP application router
  initialize: (app) ->
    unless @resourceName?
      console.log "[RESOURCE] no resource name defined"
      throw new Error(
        'a resource must define a resourceName'
      )

    endpoints = @getEndpoints()
    console.log "[RESOURCE] #{@resourceName}: found #{endpoints.length} endpoints"
    for endpoint in endpoints
      # Distinguish between default and custom endpoints
      if typeof endpoint == 'string'
        endpointName = endpoint
        endpoint = @crudEndpoints[endpointName]
        if not endpoint?
          console.log "[RESOURCE] #{@resourceName}: didn't find CRUD endpoint: #{endpointName}"
          throw new Error(
            'must provide valid endpoint or name of existing endpoint'
          )
      unless endpoint.handler?
        console.log "[RESOURCE] #{@resourceName}: no endpoint handler defined: #{endpointName}"
        throw new Error(
          'must provide valid endpoint or name of existing endpoint'
        )
      handler = @createHandler(endpoint.handler, endpoint.filters)
      @addEndpoint(app, endpoint, handler, @resourceName)

  # Implement this in a subclass to add a given endpoint to an HTTP app
  addEndpoint: (app, endpoint, handler, resourceName) ->
    console.log "[RESOURCE] #{@resourceName}: ERROR endpoint implementing not added"
    throw new Error('must override addEndpoint to add endpoints')

  # Creates an object suitable for use with paged UIs
  createDataPage: (dataArray, offset = 0, limit = -1) ->
    return {
      totalCount: dataArray.length
      count: dataArray.length
      offset: offset
      limit: limit
      objects: dataArray
    }

  # Binds route handlers to a context to make their definitions easier
  createHandler: (handler, paramFilters) =>
    (req, res) =>
      params = paramFilters.reduce((params, filter) ->
        filter.process(req, res, params)
      , {})

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
        api: @createApi(@adapter, @model)
        createApi: @createApi
        adapter: @adapter
        model: @model

      for own key, val of @context
        context[key] = val

      isError = false
      try
        returnObj = handler.call(context)
      catch e
        isError = true
        returnObj = e

      @syncResponse(
        @getResponseReplier(res),
        customContext,
        returnObj,
        isError
      )

  createApi: (Adapter, Model) ->
    new Adapter(Model)

  # Override to send something other than or in addition to, a JSON body
  getResponseReplier: (res) ->
    (args...) ->
      res.json.apply(res, args)

  isPromise: (obj) ->
    typeof obj == 'object' and obj.then?

  # Normalizes handling of synchronous and asynchronous responses
  syncResponse: (reply, customContext, returnObj, isError = false) =>
    doReply = (_returnValue, _isError) =>
      responseObj = @convertToResponse(
        customContext.statusCode, _returnValue, _isError
      )
      reply(responseObj.statusCode, responseObj.body)

    if not @isPromise(returnObj)
      if isError
        console.error(returnObj.stack)
      doReply(returnObj, isError)
    else
      returnObj
      .then((result) ->
        doReply(result, false)
      )
      .fail((error) ->
        console.error(error.stack)
        doReply(error, true)
      )
      .done()

  wrapRawResult: (result) ->
    { result: result }

  # Creates a response code and response body from a method return value
  convertToResponse: (statusCode = 200, retObj, isError = false) =>
    if not isError
      statusCode = statusCode
      if Array.isArray(retObj)
        if retObj.length == 0
          statusCode = 404
        body = @createDataPage(retObj)
      else
        body = retObj
        if not retObj?
          body = {}
          statusCode = 404
        # JSON responses must be in an object, so wrap raw responses as {result: <obj>}
        else if typeof retObj != 'object'
          body = @wrapRawResult(retObj)
    else
      # Got an error, force an error status code if not provided one
      if retObj.statusCode?
        statusCode = retObj.statusCode
      else if statusCode < 400
        statusCode = 500

      statusCode = if statusCode < 400 then 500 else statusCode
      body = retObj.data or {}
      body.error = retObj.message or 'an error occurred'
      body.object = retObj

    {statusCode, body}

  # Gets middleware to use with a given endpoint
  # TODO make this a whole lot better with some sort of mixin per resource
  getMiddleware: (route) ->
    []

module.exports = HttpResource