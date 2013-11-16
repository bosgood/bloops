# Some included middleware is defined in here

# Unpacks nested response objects:
# from: { resource: { name: "value" } }
# to:   { name: "value" }
# where `resource' is a resource's resourceName and this object
# format expectation is used if nestResponseObject is true.
NestedResponseUnpacker = (resourceName) ->
  (req, res, next) ->
    if req.body[resourceName]?
      req.body = req.body.resourceName
      break

    next()

module.exports.NestedResponseUnpacker = NestedResponseUnpacker