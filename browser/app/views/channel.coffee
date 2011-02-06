namespace 'views'

# Single channel's view in the list of channels
views.Channel = Backbone.View.extend

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