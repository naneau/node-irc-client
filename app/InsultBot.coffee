# Message Router
MessageRouter = require '../lib/MessageRouter'

# Random integer utility class
RandomInteger = require '../lib/RandomInteger'

# Simple insulting bot
class InsultBot extends MessageRouter
    
    # Constructor
    constructor: (@client) ->
        super @client
        
        # Get our nick out of the client's options
        @nick = client.opt.nick
        
        # Add a message handler for getting petted
        replies = ['take your stinking paws of me!', 'go pet mirmo', 'your mom pets me better...']
        
        # Petting handler
        @addHandler 'ACTION pets ' + @nick, (from, to, message) =>
            @client.say to, replies[RandomInteger::max replies.length]
        
        # Norm sucks handler
        @addHandler 'ACTION kicks ' + @nick, 
            (from, to, message) =>
                @client.say to, 'fuck you, ' + from

module.exports = InsultBot;