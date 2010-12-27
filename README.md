# Simple and stupid Node.js IRC client

This is mainly an attempt to mess with [CoffeeScript](http://jashkenas.github.com/coffee-script/). Start the server with:

    coffee chatbot.coffee 1234 #somechannel

It's a very simple client, that connects to freenode, and will join a channel that you specify (`#somechannel`). Browsing to your address at the port you specified (`1234`) will give you a chat interface to interact with.

## Built using

 * [CoffeeScript](http://jashkenas.github.com/coffee-script/)
 * [Node.js](http://nodejs.org/)
 * [Backbone.js](http://documentcloud.github.com/backbone/#View-el)
 * [Underscore.js](http://documentcloud.github.com/underscore/)
 * [Socket.io](http://socket.io/)
 * [Express](http://expressjs.com/)

## Dependencies

This application should run in a recent node.js environment, dependencies can be installed using [NPM](npm.mape.me). It needs:

 * CoffeeScript
 * Express
 * Socket.io
 * IRC
 * Underscore
 * Ejs