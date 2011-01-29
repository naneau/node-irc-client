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

# Manages the App's templates
class Template
    
    # Render a template
    renderTemplate: (name, templateContext = {}) ->
        
        # Ugly way of getting around CoffeeKup's compilation-into-singular-template-function
        templateContext.template = name
        
        window.template context: templateContext

# Application view
AppView = Backbone.View.extend
    
    # Constructor like
    initialize: (options) ->
        
        # Channel List
        @channelList = options.channelList
        
        @channelList.bind 'change:active', () =>
            do @renderChannel
    
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
        
# An IRC Channel
Channel = Backbone.Model.extend

    # Constructor
    initialize: () ->
        
        @set active: false
        
        @messageList = new MessageList
        
        @inputList = new MessageList
    
    # Add a message
    addMessage: (message, from) ->
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
    
    # We render this thing without a template...
    tagName: 'li'
    className: 'irc-channel'
        
    # Initialize
    initialize: () ->
        # Track active state
        @model.bind 'change:active', () =>
            if @model.get 'active'
                $(@el).addClass 'active'
            else 
                $(@el).removeClass 'active'
    
    # Make our model active if it isn't already
    makeActive: () ->
        if not @model.get 'active'
            @model.set active: true
            
    # Render
    render: () ->
        $(@el).text @model.get 'name'
        
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

# A single Message
Message = Backbone.Model.extend

    # Init
    initialize: () ->
        @set read: false

# View for a single message
MessageView = Backbone.View.extend

    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render'
        
    # Render through the template
    render: () ->
        # In this case we replace the entire node, since it's not in the dom anyway
        @el = $ Template::renderTemplate 'message', do @model.toJSON
        
        return this

# Collection of Messages
MessageList = Backbone.Collection.extend
    model: Message
    
# Main "chat list" view
ChatView = Backbone.View.extend

    # Event hash
    events:
        'keydown     input':                'inputKey'

    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render', 'newMessage', 'renderMessage', 'inputKey'
        
        # Get stuff out of the options
        @channel = options.channel
        @messageList = options.channel.messageList
        @inputList = options.channel.inputList

        # When a message is received, render it
        @messageList.bind 'add', @newMessage

    # New message has been added to the list
    newMessage: (message) ->
        @renderMessage message

    # Render the message
    renderMessage: (message) ->
        
        # We use an unordered list for the message
        @chatList or= @$('.chat');

        # Create a view for the message and render it
        message.view or= new MessageView model: message
        do message.view.render

        @chatList.append message.view.el
        @chatList.attr 'scrollTop', @chatList.attr 'scrollHeight'

    # Input box key-up handler
    inputKey: (e) ->

        # Prevent default
        do e.preventDefault if e.keyCode is 13 

        # Message has been entered and return pressed
        inputVal = do $(e.target).val
        if e.keyCode is 13 and inputVal.length > 0

            # Create new message
            @inputList.add new Message 
                message: inputVal, 
                from: 'you'

        # Reset input box
        $(e.target).val('') if e.keyCode is 13 or e.keyCode is 27

    # Resize elements
    resize: () ->
        @chatList.height $(window).height() - 120

        input = @$ 'input'
        do input.focus
        input.width @chatList.width() - 15

    # Render
    render: () ->
        @el.html Template::renderTemplate 'chat', do @channel.toJSON
        
        @chatList = @$ 'ul'
        
        # Render each message in the list
        @messageList.each (message) =>
            @renderMessage message