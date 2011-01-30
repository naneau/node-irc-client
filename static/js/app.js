(function() {
  var AppView, Channel, ChannelList, ChannelListView, ChannelView, ChatView, IRCApp, Message, MessageList, MessageView, Template;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  IRCApp = (function() {
    function IRCApp(element) {
      this.createChannelList();
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
        if (data.message === 'channelMessage') {
          return this.channelList.addMessage(data.to, data.text, data.from);
        } else if (data.message === 'channelList') {
          return this.channelList.initWithChannelList(data.channels);
        }
      }, this));
      return this.socket.connect();
    };
    IRCApp.prototype.createChannelList = function() {
      this.channelList = new ChannelList;
      return this.channelList.bind('channelInput', __bind(function(channel, message) {
        console.log('received message in ' + channel.get('name'));
        return this.socket.send({
          message: 'channelMessage',
          channel: channel.get('name'),
          text: message.get('message')
        });
      }, this));
    };
    return IRCApp;
  })();
  window.IRCApp = IRCApp;
  AppView = Backbone.View.extend({
    initialize: function(options) {
      this.channelList = options.channelList;
      this.channelList.bind('change:active', __bind(function(model, active) {
        if (active) {
          return this.renderChannel();
        }
      }, this));
      return $(window).resize(__bind(function() {
        return this.resize();
      }, this));
    },
    renderChannel: function() {
      var channel;
      channel = this.channelList.getActive();
      this.channelWrapper.children().hide();
      if (!(channel.chatView != null)) {
        channel.chatView = new ChatView({
          channel: channel
        });
        channel.chatView.render();
        this.channelWrapper.append(channel.chatView.el);
      }
      channel.chatView.el.show();
      channel.chatView.resize();
      return this.resize();
    },
    resize: function() {
      this.right.width($(window).width() - (this.left.width() + 5));
      this.right.height($('body').innerHeight());
      this.channelWrapper.height(this.right.height());
      return this.channelWrapper.children().height(this.right.height());
    },
    render: function() {
      var dom;
      dom = $(Template.prototype.renderTemplate('app'));
      this.el.html(dom);
      this.right = dom.find('#right');
      this.left = dom.find('#left');
      this.channelWrapper = this.$('#channel');
      this.channelListView = new ChannelListView({
        el: dom.find('#channel-list'),
        model: this.channelList
      });
      this.channelListView.render();
      return this.resize();
    }
  });
  Channel = Backbone.Model.extend({
    initialize: function() {
      this.set({
        active: false
      });
      this.messageList = new MessageList;
      this.inputList = new MessageList;
      return this.inputList.bind('add', __bind(function(message) {
        return this.messageList.add(message.toJSON());
      }, this));
    },
    addMessage: function(message, from) {
      return this.messageList.add(new Message({
        message: message,
        from: from
      }));
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
      this.refresh(channels);
      if (this.first()) {
        return this.makeActive(this.first());
      }
    },
    getChannel: function(name) {
      var channel;
      channel = this.get(name);
      if (!(channel != null)) {
        this.add(this.createChannel(name));
      }
      return channel;
    },
    addMessage: function(channel, message, from) {
      if (!(channel instanceof Channel)) {
        channel = this.getChannel(channel);
      }
      return channel.addMessage(message, from);
    },
    getActive: function() {
      var active;
      if (this.length = 0) {
        throw 'No channels, can\'t retrieve active';
      }
      active = this.detect(function(channel) {
        return channel.get('active');
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
      dom = $(Template.prototype.renderTemplate('channelList'));
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
      return _.bindAll(this, 'render');
    },
    render: function() {
      this.el = $(Template.prototype.renderTemplate('message', this.model.toJSON()));
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
      this.el = $(this.el);
      this.channel = options.channel;
      this.messageList = options.channel.messageList;
      this.inputList = options.channel.inputList;
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
      return this.resize();
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
      this.el.attr({
        scrollTop: this.el.attr('scrollHeight')
      });
      input = this.$('input');
      input.focus();
      return input.width(this.el.width() - 20);
    },
    render: function() {
      var dom;
      dom = Template.prototype.renderTemplate('chat', this.channel.toJSON());
      this.el = $(dom);
      this.delegateEvents();
      this.chatList = this.$('ul');
      this.messageList.each(__bind(function(message) {
        return this.renderMessage(message);
      }, this));
      this.resize();
      return this;
    }
  });
  Template = (function() {
    function Template() {}
    Template.prototype.renderTemplate = function(name, templateContext) {
      if (templateContext == null) {
        templateContext = {};
      }
      templateContext.template = name;
      return window.template({
        context: templateContext
      });
    };
    return Template;
  })();
}).call(this);
