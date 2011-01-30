# Application class
class IRCApp
    
    # Constructor, gets passed the DOM element we want to render into
    constructor: (element) ->
        
        # List of channels
        @channelList = new ChannelList
        
        # Set up socket and message handling
        do @setupSocket
        
        # Set up our view, passing along the relevant lists and such
        @appView = new AppView
            el: element,
            channelList: @channelList
            
        # Render App View
        do @appView.render
    
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
        
window.IRCApp = IRCApp

# Application view
AppView = Backbone.View.extend
    
    # Constructor like
    initialize: (options) ->
        
        # Channel List
        @channelList = options.channelList
        
        @channelList.bind 'change:active', () =>
            do @renderChannel
        
        $(window).resize () =>
            do @resize
            
    # Render a channel
    renderChannel: () ->
        channel = do @channelList.getActive
        
        # Create the channel's chat-view if it doesn't exist already
        if not channel.chatView?
            
            channel.chatView = new ChatView
                el: (@$ '#channel'),
                channel: channel
        
        # Render
        do channel.chatView.render
    
    # Set up the size
    resize: () ->
        @right.width $(window).width() - (do @left.width + 10)
        
    # Render
    render: () ->
        
        # Our dom
        dom = $(Template::renderTemplate 'app')
        
        # Include the rendered DOM in one go in our element
        @el.html dom
        
        @right = dom.find '#right'
        @left = dom.find '#left'
        
        # Channel List
        @channelListView = new ChannelListView
            el: (dom.find '#channel-list'),
            model: @channelList
        
        do @channelListView.render
        
        # initial resize
        do @resize
