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

# channel = process.argv[3] 
# channel ?= '#naneautest'
channels = ['#naneautest', '#naneautest2','#naneautest3']

nick = 'naneaubot';
server = 'irc.freenode.net';

# Instantiate the IRC Client
ircClient = new irc.Client server, nick, channels: channels

# Quick 'n dirty error handler
ircClient.addListener 'error', (error) ->
    console.log error

# # Create the insulting bot
# bot = new Bot ircClient, nick
  
# Express server
app = express.createServer()

# Set static files directory
app.use express.staticProvider __dirname + '/static' 

# Use CoffeeKup templating
app.register '.coffee', require 'coffeekup'
app.set 'view engine', 'coffee'

# Root request triggers a simple render (App is all in Backbone.js through Socket.io)
app.get '/', (request, response) ->
    response.render 'index' 

# Listen on port that is given (or use default)
port = process.argv[2] 
port ?= 8080
console.log port
app.listen parseInt port, 10

# Socket.io config
socket = io.listen app

# Log new connections
socket.on 'connection', (client) -> 
    sys.puts 'socket.io client connected'
    
    client.on 'message', (data) ->
        console.log data
        if data.message is 'channelMessage'
            ircClient.say data.channel, data.text
    
    # Send the channel list
    client.send 
        message: 'channelList'
        channels: channels
    
# Broadcast a received message
sendMessage = (from, to, message) ->
    socket.broadcast 
        message: 'channelMessage',
        from: from
        to: to, 
        text: message

# Broadcast messages received from IRC
ircClient.addListener 'message', sendMessage

# manage a backlog
backlogs = {}


# ircClient.addListener 'message', (from, to, message) ->
#      backLog.push [from, to, message]
# # For last 10 message, do a broadcast
# for message in backLog[backLog.length - 10 ... backLog.length]
#     do (message) ->
#         [from, to, message] = message
#         sendMessage from, to, message
# 
# 
# 
# # backLog = []
