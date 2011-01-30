# Application class
class IRCApp
    
    # Constructor, gets passed the DOM element we want to render into
    constructor: (element) ->
        
        # Create channel list
        do @createChannelList
        
        # Set up socket and message handling
        do @setupSocket
        
        # Set up our view, passing along the relevant lists and such
        @appView = new AppView
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

# Application view
AppView = Backbone.View.extend
    
    # Constructor like
    initialize: (options) ->
        
        # Channel List
        @channelList = options.channelList
        
        # If there's a new channel that becomes active, render that channel
        @channelList.bind 'change:active', (model, active) =>
            do @renderChannel if active
        
        $(window).resize () =>
            do @resize
            
    # Render a channel
    renderChannel: () ->
        channel = do @channelList.getActive
        
        # Hide all previous children in our wrapper (other channels)
        do @channelWrapper.children().hide
                
        # Give the channel a view if it didn't have one already
        if not channel.chatView?
            channel.chatView = new ChatView channel: channel
            
            # Initial render
            do channel.chatView.render
            @channelWrapper.append channel.chatView.el
        
        # Show the relevant element (and only that)
        do channel.chatView.el.show
        
        # Resize
        do channel.chatView.resize
        
        # Do a resize here, so we're initalized with proper dimensions
        do @resize
        
    # Set up the size
    resize: () ->
        @right.width $(window).width() - (do @left.width + 5)
        @right.height $('body').innerHeight()
        
        @channelWrapper.height @right.height()
        @channelWrapper.children().height @right.height()
        
    # Render
    render: () ->
        
        # Our dom
        dom = $(Template::renderTemplate 'app')
        
        # Include the rendered DOM in one go in our element
        @el.html dom
        
        # Find some elements in the dom and store them for easy retrieval later
        @right = dom.find '#right'
        @left = dom.find '#left'
        @channelWrapper = @$ '#channel'
        
        # Channel List
        @channelListView = new ChannelListView
            el: (dom.find '#channel-list'),
            model: @channelList
        
        do @channelListView.render
        
        # initial resize
        do @resize
