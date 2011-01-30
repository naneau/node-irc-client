templates = {}

# Time padding helper
pad = (value) ->
    value = new String value
    
    value = '0' + value if value.length is 1
    
    value
    
# Format a Date object into time string
formatTime = (date) ->
    (pad do date.getHours) + ':' + (pad do date.getMinutes) + ':' + (pad do date.getSeconds)
    
templates.app = () ->
    section class: 'app', ->
        div id: 'left', ->
            div class: 'wrap', id: 'channel-list'

        div id: 'right', ->
            div class: 'wrap', id: 'channel'
                
# Template for a chat
templates.chat = () ->
    section class: 'chat-wrap', () ->
        h2 -> @name
        
        ul class: 'chat'
    
        form ->
            input type: 'text', id: 'message', autocomplete: 'off'
        
# Single message    
templates.message = () ->
    li class: 'message', ->
        span class: 'nick', -> @from
        
        # Pretty padded timestamp    
        span class: 'timestamp', -> 
            formatTime @received
            
         @message
        
        
# Channel List
templates.channelList = () ->
    section class: 'conversations', () ->
        h2 -> 'Conversations'
        ul()

templates.channelListChannel = () ->
    li class: 'irc-channel', ->
        span class: 'name', -> @name
        span class: 'message-count'
            
# We render this thing without a template...
tagName: 'li'
className: 'irc-channel'

return templates[@template]() if templates[@template]

