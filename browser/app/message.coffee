
# A single Message
Message = Backbone.Model.extend

    # Init
    initialize: () ->
        @set read: false, received: new Date

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
        
        # jQuery-fy our @el property
        @el = $(@el)
        
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
        
        # We might need to resize
        do @resize

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
        
        # Resize with the window
        $(window).resize () =>
            do @resize
            
    # Resize elements
    resize: () ->
        # Sneakily remove some width from our title so it doesn't fall over the scrollbar... this should be possible with CSS?
        @title.width (@el.innerWidth() - 40)
        
        # Scroll to bottom
        @el.attr scrollTop: (@el.attr 'scrollHeight')
        
        # Make our input as wide as we are, minus a little padding on the right
        @input.width (@el.width() - 30)
        # Focus our input while we're at it
        do @input.focus

    # Render
    render: () ->
        dom = Template::renderTemplate 'chat', do @channel.toJSON
        @el = $(dom)
        do @delegateEvents
        
        # Cache some dom elements
        @chatList = @$ 'ul'
        @input = @$ 'input'
        @title = @$ 'h2'
        
        # Render each message in the list
        @messageList.each (message) =>
            @renderMessage message
            
        do @resize
        
        this