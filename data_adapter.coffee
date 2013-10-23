# Defines a consistent interface to a data source. Data is accessed
# through an asynchronous, promise-based API
class DataAdapter
  find: (conditions) -> @notImplemented()
  create: (properties) -> @notImplemented()
  update: (conditions, properties, upsert = false) -> @notImplemented()
  remove: (conditions) -> @notImplemented()

notImplemented = -> throw new Error('not implemented')
module.exports = DataAdapter