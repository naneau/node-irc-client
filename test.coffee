# Utilities
sys = require 'sys'
http = require 'http'
_ = require 'underscore'

#channel = '#zflounge';
channel = '#naneautest';
nick = 'naneaubot';
server = 'irc.freenode.net';

# IRC client
irc = require 'irc'

# Message Router
MessageRouter = require './lib/MessageRouter'

# Instantiate the IRC Client
client = new irc.Client server, nick, channels: [channel]

# create the message handler
router = new MessageRouter client

# Quick 'n easy RandomInteger functions
RandomInteger = 
    # Generate a random integer between start and end, note that end can not be returned itself, but start can
    between: (start, end) ->
        Math.floor start + Math.random() * end
    # Generate an integer between 0 and max, max itself will not be returned
    max: (max) ->
        RandomInteger.between 0, max

# Add a message handler for getting petted
replies = ['take your stinking paws of me!', 'go pet mirmo', 'your mom pets me better...']
    
router.addHandler 'ACTION pets ' + nick, (from, to, message) ->
    client.say to, replies[RandomInteger.max replies.length]

# Norm sucks handler
router.addHandler 'ACTION kicks ' + nick, 
    (from, to, message) ->
        client.say to, 'fuck you, ' + from