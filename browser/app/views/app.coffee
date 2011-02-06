namespace 'views'

# "Main" application view
views.App = Backbone.View.extend
    
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
            ChatView = use 'views.Chat'
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
        # @channelWrapper.children().width @right.innerWidth()
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
