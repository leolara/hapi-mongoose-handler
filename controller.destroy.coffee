###
CRUD delete
###
_ = require('lodash')

module.exports = (options) ->
 
  (request, reply) ->
    params = request.params

    Model = options.model

    Model.findOne(params).exec (err, model)->
      if err
        return reply request.hapi.Error.internal err
      if not model
        return reply request.hapi.Error.notFound("model deleted by " + JSON.stringify(params) + " not found")

      canDelete = if options.check then options.check(model, request) else true

      if canDelete
        #remove the doc
        model.remove ()->
          if options.after
            newReply = options.after model, request, 'delete'
            if newReply
              model = newReply

          return reply model
      else
        return reply request.hapi.Error.forbidden 'permission denied'
