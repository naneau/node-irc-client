(function() {
  var App, Message, MessageList, MessageView;
  App = Backbone.View.extend({
    initialize: function(options) {
      _.bindAll(this, 'render', 'newMessage', 'renderMessage');
      this.messageList = options.messageList;
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
      console.log(message.view.el, this.chatList);
      return this.chatList.append(message.view.el);
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
  window.App = App;
  MessageView = Backbone.View.extend({
    tagName: 'li',
    className: 'message',
    initialize: function(options) {
      _.bindAll(this, 'render');
      return this.template = _.template($('#message-template').html());
    },
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
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
