# Application class
class IRCApp
    # Constructor, gets passed the DOM element we want to render into
    constructor: (element) ->
        
        # Create channel list
        do @createChannelList
        
        # Set up socket and message handling
        do @setupSocket
        
        # Set up our view, passing along the relevant lists and such
        View = use 'views.App'
        @appView = new View
            el: element,
            channelList: @channelList
            
        # Render App View
        do @appView.render
    
    # Set up the Socket, and handle incoming messages
    setupSocket: () ->
        # Create socket connection
        @socket = new io.Socket;
        
        # Message handler
        @socket.on 'message', (data) =>
        
            # Incoming message for a channel
            if data.message is 'channelMessage'
                @channelList.addMessage data.to, data.text, data.from
            
            # The list of channels we're connected to
            else if data.message is 'channelList'
                # re-init the channel list
                @channelList.initWithChannelList data.channels
                
        # Connect the socket
        do @socket.connect
    
    # Create channel list and set up handler
    createChannelList: () ->
        
        # List of channels
        @channelList = new ChannelList
        
        # Listen for outgoing messages
        @channelList.bind 'channelInput', (channel, message) =>
            @socket.send
                message: 'channelMessage',
                channel: (channel.get 'name'),
                text: (message.get 'message')
            
window.IRCApp = IRCApp