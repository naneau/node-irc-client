namespace 'models'

# A single Message
models.Message = Backbone.Model.extend

    # Init
    initialize: () ->
        @set read: false, received: new Date
