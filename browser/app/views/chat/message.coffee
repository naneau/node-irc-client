namespace 'views.chat'

# View for a single message
views.chat.Message = Backbone.View.extend

    # Initialize
    initialize: (options) ->
        _.bindAll this, 'render'
        
    # Render through the template
    render: () ->
        # In this case we replace the entire node, since it's not in the dom anyway
        @el = $ Template::renderTemplate 'message', do @model.toJSON
        
        return this