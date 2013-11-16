# Some included middleware is defined in here

# Unpacks nested response objects:
# from: { resource: { name: "value" } }
# to:   { name: "value" }
# where `resource' is a resource's resourceName and this object
# format expectation is used if nestResponseObject is true.
NestedResponseUnpacker = (resourceNameMany, resourceNameOne) ->
  (req, res, next) ->
    one = req.body[resourceNameOne]
    many = req.body[resourceNameMany]
    if one?
      req.body = one
    else if many?
      req.body = many

    next()

module.exports.NestedResponseUnpacker = NestedResponseUnpacker