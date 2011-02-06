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
