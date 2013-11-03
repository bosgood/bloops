module.exports = {}

# Middleware-style parameter filter that provides a normalized set of parameters
# to a route handler method
class ParamFilter
  process: (req, res, params) -> params

module.exports.ParamFilter = new ParamFilter

# Processes all URL parameters encoded in route (e.g. /resource/:id) as { id: val }
class FromUrlParams extends ParamFilter
  process: (req, res, params) ->
    for own key, val of req.params
      params[key] = val
    params

module.exports.FromUrlParams = new FromUrlParams

# Processes all URL query string parameters
class FromQueryParams extends ParamFilter
  process: (req, res, params) ->
    for own key, val of req.query
      params[key] = val
    params

module.exports.FromQueryParams = new FromQueryParams

# Processes all parameters in the passed-in JSON string. Treats missing JSON
# string as an error
class FromJson extends ParamFilter
  process: (req, res, params) ->
    for own key, val of req.body
      params[key] = val
    params

module.exports.FromJson = new FromJson

class FromPostParams extends ParamFilter
  # TODO implement this
  # process: (req, res, params) ->
  #   params

module.exports.FromPostParams = new FromPostParams