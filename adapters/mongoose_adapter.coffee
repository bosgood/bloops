DataAdapter = require '../data_adapter'
Q = require 'q'

# Provides a data adapter for mongoose, a MongoDB client
# http://mongoosejs.com
class MongooseAdapter extends DataAdapter
  constructor: (@Model) ->
    throw new Error('must provide a type of model') unless @Model?

  list: (conditions) ->
    Q(@Model.find(conditions).exec())

  find: (conditions) ->
    @list(conditions)
    .then((items) ->
      if items?.length == 0
        return null
      else
        return items[0]
    )

  create: (properties) ->
    Q.nbind(@Model.create, @Model)(properties)

  update: (conditions, properties, upsert = false) ->
    delete properties._id if properties._id?
    Q(
      @Model.findOneAndUpdate(
        conditions,
        properties
        { upsert: upsert }
      )
      .exec()
    )

  remove: (conditions) ->
    Q(@Model.remove(conditions).exec())

module.exports = MongooseAdapter