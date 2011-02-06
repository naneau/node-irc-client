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
        
        # Set up namespacing logic
        coffeescript ->
        
            # Simple namespacing function for class separation in the browser
            namespace = (ns) ->
                parts = ns.split '.'
                parent = null
                for part in parts
                    do (part) ->
                        # Root
                        if not parent?
                            window[part] = {} if not window[part]?
                            parent = window[part]

                        # Child
                        else
                            parent[part] = {} if not parent[part]?
                            parent = parent[part]
            
            # Use a classname, exports it to the current scope
            use = (className) ->
                parts = className.split '.'

                # The last element of the parts is the actual class name
                exportName = do parts.pop

                # Root elem to shift over
                root = null
                for part in parts
                    do (part) ->
                        if not root?
                            root = window[part]
                        else 
                            root = root[part]

                        throw "#{className}'s namespace not found" if not root?

                throw "#{className} not found" if not root[exportName]?

                root[exportName]
            
            window.namespace = namespace
            window.use = use
                
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
