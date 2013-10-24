HttpResource = require './resource'

# Implements an HTTP resource served by an Express app
class ExpressHttpResource extends HttpResource
  addEndpoint: (app, endpoint, handler) ->
    app[endpoint.method.toLowerCase()](endpoint.route, handler)

module.exports = ExpressHttpResource