// Underscore.js
var _ = require('underscore');

// MessageRouter.js
// ##Very basic IRC callback router for incoming messages
// An instance is created and passed the IRC client
// Message callbacks can be added through addHandler()
// Will use `String.match()` to match and call a callback
var MessageRouter = function(client) {
    
    // Irc client
    this.client = client;
    
    // Hash of action handlers, match => [function, function, ...]
    this.actions = {};
    
    // "Main" message handler, will match the action list
    client.addListener('message', _(this.onMessage).bind(this));
    
    // Quick 'n dirty error handler
    client.addListener('error', function(error) {
        console.log('ERROR!', error);
    });
};

// Message handler
MessageRouter.prototype.onMessage = function(from, to, message) {
    _(this.actions).each(function(actions, match) {
        // for every match
        if (message.match(match)) {
            _(actions).each(function(callback) {
                callback(from, to, message);                
            });
        }
    });
};

// Add a handler for a match, match can be string or regex
MessageRouter.prototype.addHandler = function(match, callback, scope) {
    // Bind to scope if provided, 
    if (scope) {
        _(callback).bind(scope);
    }
    
    if (this.actions[match] == undefined) {
        this.actions[match] = [];
    }
    
    this.actions[match].push(callback);
};