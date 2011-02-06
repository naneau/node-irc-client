
# A single Message
Message = Backbone.Model.extend

    # Init
    initialize: () ->
        @set read: false, received: new Date

# Collection of Messages
MessageList = Backbone.Collection.extend
    model: Message