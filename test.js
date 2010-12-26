(function() {
  var Bot, bot, channel, client, http, irc, nick, server, sys, _;
  require.paths.unshift('./lib');
  sys = require('sys');
  http = require('http');
  _ = require('underscore');
  irc = require('irc');
  Bot = require('./app/InsultBot');
  channel = '#naneautest';
  nick = 'naneaubot';
  server = 'irc.freenode.net';
  client = new irc.Client(server, nick, {
    channels: [channel]
  });
  bot = new Bot(client);
}).call(this);
