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
        @client.addListener 'message', _.bind @onMessage, this
    
    # Add a handler to the message router
    addHandler: (match, callback, scope) ->
        
        # Bind to scope if provided, 
        if scope
            _.bind callback, scope
        
        # instantiate match stack if empty
        @actions[match] = [] if match not of @actions
            
        # Add the action to the stack
        @actions[match].push callback
        
    # Message handler
    onMessage: (from, to, message) ->
        for match, callbacks in @actions
            do (callbacks, match) ->
                if message.match match
                    for callback in callbacks
                        do (callback) ->
                            callback from, to, message
        
# Export the messager outer
module.exports = MessageRouter