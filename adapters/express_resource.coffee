HttpResource = require '../resource'

# Implements an HTTP resource served by an Express app
class ExpressHttpResource extends HttpResource
  addEndpoint: (app, endpoint, handler) ->
    resourceName = @resourceName
    if resourceName != '' and resourceName[0] != '/'
      resourceName = "/#{resourceName}"

    route = "#{resourceName}#{endpoint.route}"
    # Trim trailing slashes in endpoint
    if route[route.length - 1] == '/'
      route = route.substring(0, route.length - 1)

    console.log "[HTTP] adding route: #{endpoint.method} #{route}"

    @willAddEndpoint?(app, route, endpoint.method, handler)

    # Splice middleware into arguments array if any is provided
    args = [route]
    middleware = @getMiddleware()
    if middleware?.length > 0
      args = args.concat(middleware)
    args.push handler

    app[endpoint.method.toLowerCase()].apply(app, args)

    @didAddEndpoint?(app, route, endpoint.method, handler)

module.exports = ExpressHttpResource