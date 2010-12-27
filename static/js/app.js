(function() {
  var AppView, IRCApp, Message, MessageList, MessageView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  IRCApp = (function() {
    function IRCApp(element) {
      this.socket = new io.Socket;
      this.messageList = new MessageList;
      this.inputList = new MessageList;
      this.inputList.bind('add', __bind(function(message) {
        return this.socket.send({
          message: message.toJSON()
        });
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
      return this.chatList.append(message.view.el);
    },
    inputKey: function(e) {
      if (e.keyCode === 13) {
        e.preventDefault();
        this.inputList.add(new Message({
          message: $(e.target).val()
        }));
        return $(e.target).val('');
      }
    },
    render: function() {
      var dom;
      dom = $(this.template());
      this.chatList = dom.find('ul');
      this.el.append(dom);
      return this.messageList.each(function(message) {
        return renderMessage(message);
      });
    }
  });
  MessageView = Backbone.View.extend({
    tagName: 'li',
    className: 'message',
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
  window.Message = Message;
  MessageList = Backbone.Collection.extend({
    model: Message
  });
  window.MessageList = MessageList;
}).call(this);
