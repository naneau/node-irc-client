# Application class
class IRCApp
    
    # Constructor
    constructor: (element) ->
        
        # Create socket connection
        @socket = new io.Socket;
        
        # List of messages received
        @messageList = new MessageList;
        
        # List of messages (to be) sent
        @inputList = new MessageList;
        
        # When a new message is added to the input list, send it to the server, but also show it as a message
        @inputList.bind 'add', (message) =>
            @socket.send message: message.toJSON()
            
            # We have to "clone" the message here, before adding it to our own message list
            @messageList.add new Message message.toJSON()
        
        # Message handler
        @socket.on 'message', (data) =>
            if data['message']
                @messageList.add new Message data['message']
        
        # Main view for the application
        @appView = new AppView
            el: element,
            messageList: @messageList,
            inputList: @inputList
        
        # Render
        @appView.render()
        
        # Connect the socket
        @socket.connect()
        
window.IRCApp = IRCApp

# Main "chat list" view
AppView = Backbone.View.extend
    
    # Event hash
    events:
        'keydown     input':     'inputKey'
        
    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render', 'newMessage', 'renderMessage', 'inputKey'
        
        # Get stuff out of the options
        @messageList = options.messageList
        @inputList = options.inputList
        
        # When a message is received, render it
        @messageList.bind 'add', @newMessage
        
        # Create template
        @template = _.template $('#app-template').html()
        
    # New message has been added to the list
    newMessage: (message) ->
        @renderMessage message
    
    # Render the message
    renderMessage: (message) ->
        
        # We use an unordered list for the message
        @chatList or= @$('ul');
        
        # Create a view for the message and render it
        message.view or= new MessageView model: message
        message.view.render()
        
        @chatList.append message.view.el
        @chatList.attr 'scrollTop', @chatList.attr 'scrollHeight'
    
    # Input box key-up handler
    inputKey: (e) ->
        
        # Prevent default
        e.preventDefault() if e.keyCode is 13 
        
        # Message has been entered and return pressed
        inputVal = $(e.target).val()
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
        input.focus()
        input.width @chatList.width() - 15
        
    # Render
    render: () ->
        dom = $(@template())
        
        # Set chat list up as temporary (non-included) dom, so we can include it as a chunk (only one re-draw)
        @chatList = dom.find 'ul'
        
        # Render each message in the list
        @messageList.each (message) ->
            renderMessage message
            
        # Include the rendered DOM in one go in our element
        @el.append dom
        
        # This will still cause a redraw...
        @resize()
    
# View for a single message
MessageView = Backbone.View.extend

    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render'
        
        # Create template
        @template = _.template $('#message-template').html()
        
    # Render through the template
    render: () ->
        # In this case we replace the entire node, since it's not in the dom anyway
        @el = $ @template @model.toJSON()
        
        return this

# A single Message
Message = Backbone.Model.extend()

# Collection of Messages
MessageList = Backbone.Collection.extend
    model: Message