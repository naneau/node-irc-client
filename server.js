// Utilities
var irc = require('irc');
var sys = require('sys');
var _ = require('underscore');

// Message router
var Router = require('./lib/MessageRouter');

// Channel
// const channel = '#zflounge';
const channel = '#naneautest';
const nick = 'naneaubot';
const server = 'irc.freenode.net';

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