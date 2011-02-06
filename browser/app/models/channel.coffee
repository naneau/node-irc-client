namespace 'models'

# An IRC Channel
models.Channel = Backbone.Model.extend

    # Constructor
    initialize: () ->
        
        @set active: false
        
        # Incoming and outgoing list of messages
        MessageList = use 'models.message.List'
        @messageList = new MessageList
        @inputList = new MessageList
        
        # Add outgoing messages to the incoming list
        @inputList.bind 'add', (message) =>
            # Add the outgoing message to the incoming list
            @messageList.add do message.toJSON
        
    # Add a message
    addMessage: (message, from) ->
        Message = use 'models.Message'
        @messageList.add new Message 
            message: message, 
            from: from