(function() {
  var AppView, IRCApp, Message, MessageList, MessageView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  IRCApp = (function() {
    function IRCApp(element) {
      this.socket = new io.Socket;
      this.messageList = new MessageList;
      this.inputList = new MessageList;
      this.inputList.bind('add', __bind(function(message) {
        this.socket.send({
          message: message.toJSON()
        });
        return this.messageList.add(new Message(message.toJSON()));
      }, this));
      this.socket.on('message', __bind(function(data) {
        if (data['message']) {
          return this.messageList.add(new Message(data['message']));
        }
      }, this));
      this.appView = new AppView({
        el: element,
        messageList: this.messageList,
        inputList: this.inputList
      });
      this.appView.render();
      this.socket.connect();
    }
    return IRCApp;
  })();
  window.IRCApp = IRCApp;
  AppView = Backbone.View.extend({
    events: {
      'keydown     input': 'inputKey'
    },
    initialize: function(options) {
      _.bindAll(this, 'render', 'newMessage', 'renderMessage', 'inputKey');
      this.messageList = options.messageList;
      this.inputList = options.inputList;
      this.messageList.bind('add', this.newMessage);
      return this.template = _.template($('#app-template').html());
    },
    newMessage: function(message) {
      return this.renderMessage(message);
    },
    renderMessage: function(message) {
      this.chatList || (this.chatList = this.$('ul'));
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
      var dom;
      dom = $(this.template());
      this.chatList = dom.find('ul');
      this.messageList.each(function(message) {
        return renderMessage(message);
      });
      this.el.append(dom);
      return this.resize();
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
  Message = Backbone.Model.extend();
  MessageList = Backbone.Collection.extend({
    model: Message
  });
}).call(this);
