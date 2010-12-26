# MessageRouter.js
#
# *Very* basic IRC callback router for incoming messages
# An instance is created and passed the IRC client
# Message callbacks can be added through addHandler()
# Will use `String.match()` to match and call a callback

# Utilities Underscore.js
_ = require('underscore')

class MessageRouter 
    
    # Constructor, takes the IRC client
    constructor: (@client)  ->
        # Hash of action handlers, match => [function, function, ...]
        @actions = {}
    
        # "Main" message handler, will match the action list
        client.addListener 'message', _.bind @onMessage this
    
        # Quick 'n dirty error handler
        client.addListener 'error', (error) ->
            console.log 'ERROR!', error
    
    # Message handler
    onMessage: (from, to, message) ->
        _.each @actions, (actions, match) ->
            if message.match match
                _.each actions, (callback) ->
                    callback from, to, message
    
    # Add a handler to the message router
    addHandler: (match, callback, scope) ->
        
        # Bind to scope if provided, 
        if scope
            _.bind callback, scope
        
        # instantiate match stack if empty
        if @actions[match] == undefined
            @actions[match] = []
            
        # Add the action to the stack
        @actions[match].push(callback)
        
# Export the messager outer
module.exports = MessageRouter