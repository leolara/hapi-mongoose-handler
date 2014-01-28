###
CRUD find
###
_ = require 'lodash'

module.exports = (options) ->

  (request, reply) ->
    params = _.merge request.query, request.params
    Model = options.model
    #if the model is not mongoose the run and hope that it gives us a mongoose model
    if not Model.modelName?
      Model = Model params
    
    if options.before
      options.before params

    limit = Number params.limit
    sort = params.sort or params.order or undefined
    skip = Number(params.skip or params.offset) or undefined
    config = {}

    #Build the query
    #Remove undefined params
    #(as well as limit, skip, and sort)
    where = _.transform params, (result, param, key)->
      if key not in ['limit', 'offset', 'skip', 'sort', 'client'] and not options.queries?[key] and param
        if _.isObject param
          param = _.transform param, (result, prop, key)->
            result["$"+key] = prop

        result[key] = param

    #add queries
    if options.queries
      for param, query of options.queries
        if params[param]
          where = _.merge(where, query(params[param], params))

    #add config
    if options.config
      config = options.config(request.server.settings.app.api)

    #add limit
    if config.maxLimit
      if _.isNaN(limit) or limit > config.maxLimit
        limit = config.maxLimit

    #add order
    if config.defaultOrder and not sort
      sort = config.defaultOrder

    Model.find(where).sort(sort).skip(skip).limit(limit).exec (err, models) ->
      # An error occurred
      if err
        return reply request.hapi.Error.internal err

      #Build set of model values
      modelValues = []
      models.forEach (model) ->
        modelValues.push model

      #subscirbe to this query
      if options.pubsub and params.client
        request.server.plugins['metageo-pubsub'].sub params.client, params

      #add wrapper
      if options.after
        #some of the params may have mutated
        params.sort = sort
        params.limit = limit
        params.skip = skip
        modelValues = options.after modelValues, 'find', params

      return reply modelValues
