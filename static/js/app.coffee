# Main "chat list" view
App = Backbone.View.extend
    # events:
        
    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render', 'newMessage', 'renderMessage'
        
        @messageList = options.messageList
        
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
        
        console.log message.view.el, @chatList
        
        @chatList.append message.view.el
        
    # Render
    render: () ->
        dom = $(@template())
        
        # Set chat list up as temporary (non-included) dom, so we can include it as a chunk (only one re-draw)
        @chatList = dom.find 'ul'
        
        # Include the rendered DOM in one go in our element
        @el.append dom
        
        # Render each message in the list
        @messageList.each (message) ->
            renderMessage message
            
        

# Export the App class as a global
window.App = App;

# View for a single message
MessageView = Backbone.View.extend
    tagName: 'li'
    
    className: 'message'
        
    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render'
        
        # Create template
        @template = _.template $('#message-template').html()
        
    # Render through the template
    render: () ->
        $(@el).html @template @model.toJSON()
        
        return this

# A single Message
Message = Backbone.Model.extend()
window.Message = Message

# Collection of Messages
MessageList = Backbone.Collection.extend
    model: Message
window.MessageList = MessageList