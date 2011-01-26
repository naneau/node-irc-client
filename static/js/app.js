(function() {
  var AppView, Channel, ChannelList, ChannelListView, ChannelView, ChatView, IRCApp, Message, MessageList, MessageView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  IRCApp = (function() {
    function IRCApp(element) {
      this.channelList = new ChannelList;
      this.setupSocket();
      this.appView = new AppView({
        el: element,
        channelList: this.channelList
      });
      this.appView.render();
    }
    IRCApp.prototype.setupSocket = function() {
      this.socket = new io.Socket;
      this.socket.on('message', __bind(function(data) {
        console.log(data);
        if (data.message === 'channelMessage') {
          return this.channelList.addMessage(data.to, data.text);
        } else if (data.message === 'channelList') {
          return this.channelList.initWithChannelList(data.channels);
        }
      }, this));
      return this.socket.connect();
    };
    return IRCApp;
  })();
  window.IRCApp = IRCApp;
  AppView = Backbone.View.extend({
    initialize: function(options) {
      this.channelList = options.channelList;
      this.channelList.bind('add', this.render);
      return this.template = _.template($('#app-template').html());
    },
    render: function() {
      var dom;
      dom = $(this.template());
      this.el.html(dom);
      this.channelListView = new ChannelListView({
        el: dom.find('#channel-list'),
        model: this.channelList
      });
      this.channelListView.render();
      if (this.channelList.first() != null) {
        this.ChatView = new ChatView({
          el: dom.find('.chat'),
          messageList: this.channelList.first().messageList,
          inputList: this.channelList.first().inputList
        });
        return this.ChatView.render();
      }
    }
  });
  Channel = Backbone.Model.extend({
    initialize: function() {
      this.set({
        active: false
      });
      this.messageList = new MessageList;
      return this.inputList = new MessageList;
    },
    addMessage: function(message) {
      return this.messageList.add(new Message(message));
    }
  });
  ChannelList = Backbone.Collection.extend({
    model: Channel,
    initialize: function() {
      return this.bind('change:active', __bind(function(activeChannel, active) {
        if (active) {
          return this.each(__bind(function(channel) {
            if (channel.get('id') !== activeChannel.get('id')) {
              return channel.set({
                active: false
              });
            }
          }, this));
        }
      }, this));
    },
    createChannel: function(name) {
      var channel;
      channel = new Channel({
        id: name,
        name: name
      });
      channel.inputList.bind('add', __bind(function(message) {
        return this.trigger('channelInput', channel, message);
      }, this));
      return channel;
    },
    initWithChannelList: function(names) {
      var channels, name, _fn, _i, _len;
      channels = [];
      _fn = __bind(function(name) {
        return channels.push(this.createChannel(name));
      }, this);
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        _fn(name);
      }
      return this.refresh(channels);
    },
    getChannel: function(name) {
      var channel;
      channel = this.get(name);
      if (!(channel != null)) {
        this.add(this.createChannel(name));
      }
      return channel;
    },
    addMessage: function(channel, message) {
      if (!(channel instanceof Channel)) {
        channel = this.getChannel(channel);
      }
      return channel.addMessage(message);
    },
    getActive: function() {
      var active;
      if (this.length = 0) {
        throw 'No channels, can\'t retrieve active';
      }
      active = this.any(function(channel) {
        return this.get('active');
      });
      if (!(active != null)) {
        return this.first();
      }
      return active;
    },
    makeActive: function(channel) {
      this.each(function(channel) {
        return channel.set({
          active: false
        });
      });
      if (!(channel instanceof Channel)) {
        channel = this.getChannel(channel);
      }
      return channel.set({
        active: true
      });
    }
  });
  ChannelView = Backbone.View.extend({
    events: {
      'click': 'makeActive'
    },
    tagName: 'li',
    className: 'irc-channel',
    initialize: function() {
      return this.model.bind('change:active', __bind(function() {
        if (this.model.get('active')) {
          return $(this.el).addClass('active');
        } else {
          return $(this.el).removeClass('active');
        }
      }, this));
    },
    makeActive: function() {
      if (!this.model.get('active')) {
        return this.model.set({
          active: true
        });
      }
    },
    render: function() {
      $(this.el).text(this.model.get('name'));
      return this;
    }
  });
  ChannelListView = Backbone.View.extend({
    initialize: function() {
      this.template = _.template($('#channel-list-template').html());
      return this.model.bind('refresh', __bind(function() {
        return this.render();
      }, this));
    },
    changeConversation: function(e) {
      var all, li;
      e.preventDefault();
      li = $(e.target).closest('li');
      all = this.$('.conversations li');
      all.removeClass('active');
      return li.addClass('active');
    },
    render: function() {
      var dom, list;
      dom = $(this.template());
      list = dom.find('ul');
      this.model.each(function(channel) {
        if (!(channel.view != null)) {
          channel.view = new ChannelView({
            model: channel
          });
        }
        channel.view.render();
        return list.append(channel.view.el);
      });
      return this.el.html(dom);
    }
  });
  Message = Backbone.Model.extend({
    initialize: function() {
      return this.set({
        read: false
      });
    }
  });
  MessageView = Backbone.View.extend({
    initialize: function(options) {
      _.bindAll(this, 'render');
      return this.template = _.template($('#message-template').html());
    },
    render: function() {
      this.el = $(this.template(this.model.toJSON()));
      return this;
    }
  });
  MessageList = Backbone.Collection.extend({
    model: Message
  });
  ChatView = Backbone.View.extend({
    events: {
      'keydown     input': 'inputKey'
    },
    initialize: function(options) {
      _.bindAll(this, 'render', 'newMessage', 'renderMessage', 'inputKey');
      this.messageList = options.messageList;
      this.inputList = options.inputList;
      return this.messageList.bind('add', this.newMessage);
    },
    newMessage: function(message) {
      return this.renderMessage(message);
    },
    renderMessage: function(message) {
      this.chatList || (this.chatList = this.$('.chat'));
      message.view || (message.view = new MessageView({
        model: message
      }));
      message.view.render();
      this.chatList.append(message.view.el);
      return this.chatList.attr('scrollTop', this.chatList.attr('scrollHeight'));
    },
    inputKey: function(e) {
      var inputVal;
      if (e.keyCode === 13) {
        e.preventDefault();
      }
      inputVal = $(e.target).val();
      if (e.keyCode === 13 && inputVal.length > 0) {
        this.inputList.add(new Message({
          message: inputVal,
          from: 'you'
        }));
      }
      if (e.keyCode === 13 || e.keyCode === 27) {
        return $(e.target).val('');
      }
    },
    resize: function() {
      var input;
      this.chatList.height($(window).height() - 120);
      input = this.$('input');
      input.focus();
      return input.width(this.chatList.width() - 15);
    },
    render: function() {
      return this.messageList.each(function(message) {
        return renderMessage(message);
      });
    }
  });
}).call(this);
