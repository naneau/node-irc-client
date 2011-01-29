# Root of our html
body ->
    html ->
      head ->
        meta charset: 'utf-8'
        
        title "#{@title or 'IRC'}"
        
        link rel: 'stylesheet', href: '/css/style.css'
        
        # Libraries
        script src: '/js/lib/jquery.js'
        script src: 'js/lib/jquery.js'
        script src: 'js/lib/underscore.js'
        script src: 'js/lib/backbone.js'
        script src: 'socket.io/socket.io.js'
        
        # App js
        script src: 'js/templates.js'
        script src: 'js/app.js'
        
        # Coffeescript
        coffeescript ->
        
            # App config
            config = server: '10.0.1.8', port: 8080
            
            # On document load
            $(document).ready () ->
                
                # Use moustache style templates
                _.templateSettings = interpolate: /\{\{(.+?)\}\}/g
                
                # Instantiate app
                app = new IRCApp $('#app')
                
      body ->
        div id: 'app'
