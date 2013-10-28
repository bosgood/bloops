module.exports = {}

# Middleware-style parameter filter that provides a normalized set of parameters
# to a route handler method
class ParamFilter
  process: (req, res, params) -> params

module.exports.ParamFilter = new ParamFilter

# Processes all URL parameters
class FromUrlParams extends ParamFilter
  process: (req, res, params) ->
    for own key, val of req.params
      params[key] = val
    params

module.exports.FromUrlParams = new FromUrlParams

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