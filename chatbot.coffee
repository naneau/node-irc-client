# Add ./lib to the require paths for easy extending
require.paths.unshift './lib'

# Utilities
sys = require 'sys'
http = require 'http'
_ = require 'underscore'

# IRC client
irc = require 'irc'

# Bot
Bot = require './app/InsultBot'

# channel = '#zflounge';
channel = '#naneautest';
nick = 'naneaubot';
server = 'irc.freenode.net';

# Instantiate the IRC Client
client = new irc.Client server, nick, channels: [channel]

# Quick 'n dirty error handler
client.addListener 'error', (error) ->
    console.log error

# Create the insulting bot
bot = new Bot client, nick