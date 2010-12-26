(function() {
  var MessageRouter, RandomInteger, channel, client, http, irc, nick, replies, router, server, sys, _;
  sys = require('sys');
  http = require('http');
  _ = require('underscore');
  channel = '#naneautest';
  nick = 'naneaubot';
  server = 'irc.freenode.net';
  irc = require('irc');
  MessageRouter = require('./lib/MessageRouter');
  client = new irc.Client(server, nick, {
    channels: [channel],
    'do-test': test
  });
  router = new MessageRouter(client);
  RandomInteger = {
    between: function(start, end) {
      return Math.floor(start + Math.random() * end);
    },
    max: function(max) {
      return RandomInteger.between(0, max);
    }
  };
  replies = ['take your stinking paws of me!', 'go pet mirmo', 'your mom pets me better...'];
  router.addHandler('ACTION pets ' + nick, function(from, to, message) {
    return client.say(to, replies[RandomInteger.max(replies.length)]);
  });
  router.addHandler('ACTION kicks ' + nick, function(from, to, message) {
    return client.say(to, 'fuck you, ' + from);
  });
}).call(this);
