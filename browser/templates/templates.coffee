templates = {}

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

