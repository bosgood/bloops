# Defines errors that can occur while processing a request and their
# corresponding HTTP response codes

# An error occurred because of invalid request parameters
class UserError extends Error
  constructor: (@message) ->
  statusCode: 400

# Could not find the requested object(s)
class NotFoundError extends Error
  constructor: (@message) ->
  statusCode: 404

module.exports = {UserError, NotFoundError}