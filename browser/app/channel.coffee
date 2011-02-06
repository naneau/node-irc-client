# An IRC Channel
Channel = Backbone.Model.extend

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
        
# List of Channels
ChannelList = Backbone.Collection.extend

    model: Channel
    
    # Constructor
    initialize: () ->
        
        # There can only be one channel active
        @bind 'change:active', (activeChannel, active) =>
            if active
                @each (channel) =>
                    if channel.get('id') isnt activeChannel.get('id')
                        channel.set active: false
            
    # Create a channel
    createChannel: (name) ->
        
        # Channels get an ID that's really their name, for easy retreival
        channel = new Channel
            id: name,
            name: name
        
        # Listen to new messages in the channel's input list
        channel.inputList.bind 'add', (message) =>
            # Trigger event
            @trigger 'channelInput', channel, message
            
        channel
    
    # (Re-) init with a list of channel names
    initWithChannelList: (names) ->
        
        # Create an array of new channel lists
        channels = []
        for name in names
            do (name) =>
                channels.push @createChannel name
        
        # "Refresh" ourselves with that list
        @refresh channels
        
        @makeActive do @first if do @first
        
    # Get a channel by name, with lazy init
    getChannel: (name) ->
        channel = @get name
        
        # Create if it doesn't exist
        if not channel?
            @add @createChannel name
        
        channel
        
    # Add a message to a channel
    addMessage: (channel, message, from) ->
        
        # Fetch channel if string is given
        channel = @getChannel channel if channel not instanceof Channel
        
        channel.addMessage message, from
        
    # Get the active channel
    getActive: () ->
        
        # Make sure we have at least one
        throw 'No channels, can\'t retrieve active' if @length = 0
        
        active = @detect (channel) ->
            channel.get 'active'

        return do @first if not active?
        
        active
    
    # Make a channel active
    makeActive: (channel) ->
        
        # Make sure all other channels aren't active
        @each (channel) ->
            channel.set active:false
        
        # Retrieve if string given
        channel = @getChannel channel if channel not instanceof Channel
        
        # Make the channel active
        channel.set active:true

# Single channel's view in the list of channels
ChannelView = Backbone.View.extend

    # Event hash
    events: 
        'click':      'makeActive'
    
        
    # Initialize
    initialize: () ->
        @unread = 0
        
        # Track active state
        @model.bind 'change:active', () =>
            if @model.get 'active'
                do @hideMessageCount
                $(@el).addClass 'active'
            else 
                $(@el).removeClass 'active'
                
        # Track unread messages
        @model.messageList.bind 'add', () =>
            if not (@model.get 'active')
                @unread++
                do @showUnread
            
    # Make our model active if it isn't already
    makeActive: () ->
        if not @model.get 'active'
            @model.set active: true
            
    # Hide the message counter, and reset
    hideMessageCount: () ->
        @unread = 0
        @messageCountEl.text @unread        
        do @messageCountEl.hide
    
    # Update and show unread message count
    showUnread: () ->
        return if @model.get 'active'
        
        @messageCountEl.text @unread
        do @messageCountEl.show
        
    # Render
    render: () ->
        # Replace our element with a rendered one
        dom = $(Template::renderTemplate 'channelListChannel')
        @el = dom
        do @delegateEvents
        
        nameEl = @el.find '.name'
        nameEl.text @model.get 'name'
        
        # Find and hide the message count, we'll show once there are messages
        @messageCountEl = @el.find '.message-count'
        do @hideMessageCount
        
        this

# View for the channel list
ChannelListView = Backbone.View.extend

    # Init
    initialize: () ->
        # @model.bind 'add', @render
        @model.bind 'refresh', () =>
            do @render
        
    # Change conversation
    changeConversation: (e) ->
        do e.preventDefault

        li = $(e.target).closest 'li'

        # Remove active from all
        all = @$ '.conversations li'
        all.removeClass 'active'

        # Add it to our target
        li.addClass 'active'
        
    render: () ->
        dom = $(Template::renderTemplate 'channelList')
        
        list = dom.find 'ul'
        
        # Render each channel separately
        @model.each (channel) ->
            
            # Create the channel's view if it doesn't exist already
            if not channel.view?
                channel.view = new ChannelView
                    model: channel
            
            # Render
            do channel.view.render
            
            # Append the rendered element to the list
            list.append  channel.view.el
            
        @el.html dom
