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