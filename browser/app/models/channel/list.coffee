namespace 'models.channel'

# List of Channels
ChannelList = Backbone.Collection.extend

    # model: Channel
    
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
        Channel = use 'models.Channel'
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
        Channel = use 'models.Channel'
        channel = @getChannel channel if channel not instanceof Channel
        
        # Make the channel active
        channel.set active:true