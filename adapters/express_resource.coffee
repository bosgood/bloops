HttpResource = require '../resource'

# Implements an HTTP resource served by an Express app
class ExpressHttpResource extends HttpResource
  addEndpoint: (app, endpoint, handler) ->
    resourceName = @resourceName
    if resourceName != '' and resourceName[0] != '/'
      resourceName = "/#{resourceName}"

    route = "#{resourceName}/#{endpoint.route}"
    console.log "[HTTP] adding route: #{route}"
    app[endpoint.method.toLowerCase()](route, handler)

module.exports = ExpressHttpResource