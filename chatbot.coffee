# Add ./lib to the require paths for easy extending
require.paths.unshift './lib'

# Utilities
sys = require 'sys'
http = require 'http'
_ = require 'underscore'

# Express framework
express = require 'express'

# Socket.io
io = require 'socket.io'

# IRC client
irc = require 'irc'

# Bot
Bot = require './app/InsultBot'

# channel = '#zflounge';
channel = '#naneautest';
nick = 'naneaubot';
server = 'irc.freenode.net';

# Instantiate the IRC Client
ircClient = new irc.Client server, nick, channels: [channel]

# Quick 'n dirty error handler
ircClient.addListener 'error', (error) ->
    console.log error

# # Create the insulting bot
# bot = new Bot ircClient, nick
  
# Express server
app = express.createServer()

# Set static files directory
app.use express.staticProvider __dirname + '/static' 

# Use EJS templating
app.set 'view engine', 'ejs'

# Root request triggers a simple render (App is all in Backbone.js through Socket.io)
app.get '/', (request, response) ->
    response.render 'index' 

# Listen on port 80
app.listen 8080

# Socket.io config
socket = io.listen app

# Log new connections
socket.on 'connection', (client) -> 
    sys.puts 'socket.io client connected'
    
    client.on 'message', (data) ->
        if data.message
            ircClient.say channel, data.message.message
    
    # For last 10 message, do a broadcast
    for message in backLog[backLog.length - 10 ... backLog.length]
        do (message) ->
            [from, to, message] = message
            sendMessage from, to, message
            
# Broadcast a received message
sendMessage = (from, to, message) ->
    socket.broadcast message:
        from: from
        to: to, 
        message: message

# Broadcast messages received from IRC
ircClient.addListener 'message', sendMessage

# manage a backlog
backLog = []
ircClient.addListener 'message', (from, to, message) ->
    backLog.push [from, to, message]
