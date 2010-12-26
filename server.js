var irc = require('irc');
var sys = require('sys');
var _ = require('underscore');

// Channel
const channel = '#zflounge';
// const channel = '#naneautest';
const nick = 'naneaubot';
const server = 'irc.freenode.net';

// *Very* basic IRC callback router for incoming messages
var Router = function(client) {
    
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
Router.prototype.onMessage = function(from, to, message) {
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
Router.prototype.addHandler = function(match, callback) {
    if (this.actions[match] == undefined) {
        this.actions[match] = [];
    }
    
    this.actions[match].push(callback);
};

// Create client
var client = new irc.Client(server, nick, {
    channels: [channel]
});

// Set up the router
var router = new Router(client);

// Add a message handler for getting petted
var replies = ['take your stinking paws of me!', 'go pet mirmo', 'your mom pets me better...'];
router.addHandler('ACTION pets ' + nick, function(from, to, message) {
    var index = Math.floor(Math.random() * replies.length);
    client.say(to, replies[index]);
});

// Norm sucks handler
router.addHandler('ACTION kicks ' + nick, function(from, to, message) {
    client.say(to, 'fuck you, norm');
});