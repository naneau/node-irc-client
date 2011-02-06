(function() {
  var ChannelList, IRCApp, Template;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  IRCApp = (function() {
    function IRCApp(element) {
      var View;
      this.createChannelList();
      this.setupSocket();
      View = use('views.App');
      this.appView = new View({
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
  namespace('models.channel');
  ChannelList = Backbone.Collection.extend({
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
      var Channel, channel;
      Channel = use('models.Channel');
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
      var Channel;
      this.each(function(channel) {
        return channel.set({
          active: false
        });
      });
      Channel = use('models.Channel');
      if (!(channel instanceof Channel)) {
        channel = this.getChannel(channel);
      }
      return channel.set({
        active: true
      });
    }
  });
  namespace('models');
  models.Channel = Backbone.Model.extend({
    initialize: function() {
      var MessageList;
      this.set({
        active: false
      });
      MessageList = use('models.message.List');
      this.messageList = new MessageList;
      this.inputList = new MessageList;
      return this.inputList.bind('add', __bind(function(message) {
        return this.messageList.add(message.toJSON());
      }, this));
    },
    addMessage: function(message, from) {
      var Message;
      Message = use('models.Message');
      return this.messageList.add(new Message({
        message: message,
        from: from
      }));
    }
  });
  namespace('models.message');
  models.message.List = Backbone.Collection.extend({});
  namespace('models');
  models.Message = Backbone.Model.extend({
    initialize: function() {
      return this.set({
        read: false,
        received: new Date
      });
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
  namespace('views');
  views.App = Backbone.View.extend({
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
      var ChatView, channel;
      channel = this.channelList.getActive();
      this.channelWrapper.children().hide();
      if (!(channel.chatView != null)) {
        ChatView = use('views.Chat');
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
      var ChannelListView, dom;
      dom = $(Template.prototype.renderTemplate('app'));
      this.el.html(dom);
      this.right = dom.find('#right');
      this.left = dom.find('#left');
      this.channelWrapper = this.$('#channel');
      ChannelListView = use('views.menu.Channels');
      this.channelListView = new ChannelListView({
        el: dom.find('#channel-list'),
        model: this.channelList
      });
      this.channelListView.render();
      return this.resize();
    }
  });
  namespace('views');
  views.Channel = Backbone.View.extend({
    events: {
      'click': 'makeActive'
    },
    initialize: function() {
      this.unread = 0;
      this.model.bind('change:active', __bind(function() {
        if (this.model.get('active')) {
          this.hideMessageCount();
          return $(this.el).addClass('active');
        } else {
          return $(this.el).removeClass('active');
        }
      }, this));
      return this.model.messageList.bind('add', __bind(function() {
        if (!(this.model.get('active'))) {
          this.unread++;
          return this.showUnread();
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
    hideMessageCount: function() {
      this.unread = 0;
      this.messageCountEl.text(this.unread);
      return this.messageCountEl.hide();
    },
    showUnread: function() {
      if (this.model.get('active')) {
        return;
      }
      this.messageCountEl.text(this.unread);
      return this.messageCountEl.show();
    },
    render: function() {
      var dom, nameEl;
      dom = $(Template.prototype.renderTemplate('channelListChannel'));
      this.el = dom;
      this.delegateEvents();
      nameEl = this.el.find('.name');
      nameEl.text(this.model.get('name'));
      this.messageCountEl = this.el.find('.message-count');
      this.hideMessageCount();
      return this;
    }
  });
  namespace('views.chat');
  views.chat.Message = Backbone.View.extend({
    initialize: function(options) {
      return _.bindAll(this, 'render');
    },
    render: function() {
      this.el = $(Template.prototype.renderTemplate('message', this.model.toJSON()));
      return this;
    }
  });
  namespace('views');
  views.Chat = Backbone.View.extend({
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
      var MessageView;
      this.chatList || (this.chatList = this.$('.chat'));
      MessageView = use('views.chat.Message');
      message.view || (message.view = new MessageView({
        model: message
      }));
      message.view.render();
      this.chatList.append(message.view.el);
      return this.resize();
    },
    inputKey: function(e) {
      var Message, inputVal;
      if (e.keyCode === 13) {
        e.preventDefault();
      }
      inputVal = $(e.target).val();
      if (e.keyCode === 13 && inputVal.length > 0) {
        Message = use('models.Message');
        this.inputList.add(new Message({
          message: inputVal,
          from: 'you'
        }));
      }
      if (e.keyCode === 13 || e.keyCode === 27) {
        $(e.target).val('');
      }
      return $(window).resize(__bind(function() {
        return this.resize();
      }, this));
    },
    resize: function() {
      this.title.width(this.el.innerWidth() - 40);
      this.el.attr({
        scrollTop: this.el.attr('scrollHeight')
      });
      this.input.width(this.el.width() - 30);
      return this.input.focus();
    },
    render: function() {
      var dom;
      dom = Template.prototype.renderTemplate('chat', this.channel.toJSON());
      this.el = $(dom);
      this.delegateEvents();
      this.chatList = this.$('ul');
      this.input = this.$('input');
      this.title = this.$('h2');
      this.messageList.each(__bind(function(message) {
        return this.renderMessage(message);
      }, this));
      this.resize();
      return this;
    }
  });
  namespace('views.menu');
  views.menu.Channels = Backbone.View.extend({
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
        var ChannelView;
        if (!(channel.view != null)) {
          ChannelView = use('views.Channel');
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
}).call(this);
