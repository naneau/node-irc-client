namespace 'views.menu.channels'

# View for the channel list
views.menu.channels.List = Backbone.View.extend

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
                ChannelView = use 'views.menu.Channel'
                channel.view = new ChannelView
                    model: channel
            
            # Render
            do channel.view.render
            
            # Append the rendered element to the list
            list.append  channel.view.el
            
        @el.html dom
