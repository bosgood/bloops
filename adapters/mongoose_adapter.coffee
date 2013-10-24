DataAdapter = require './data_adapter'
Q = require 'q'

# Provides a data adapter for mongoose, a MongoDB client
# http://mongoosejs.com
class MongooseAdapter extends DataAdapter
  constructor: (@Model) ->
    throw new Error('must provide a type of model') unless @Model?

  find: (conditions) ->
    Q(@Model.find(conditions).exec())

  create: (properties) ->
    Q.nbind(@Model.create, @Model)(properties)

  update: (conditions, properties, upsert = false) ->
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