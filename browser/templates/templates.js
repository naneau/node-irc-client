(function() {
  var app, templateResult;
  console.log(this);
  app = function() {
    return section({
      "class": 'app'
    }, function() {
      div({
        id: 'left'
      }, function() {
        return div({
          "class": 'wrap',
          id: 'channel-list'
        });
      });
      return div({
        id: 'right'
      }, function() {
        return div({
          "class": 'wrap',
          id: 'channel'
        });
      });
    });
  };
  templateResult = (function() {
    switch (this.template) {
      case 'app':
        return app();
    }
  }).call(this);
  return templateResult;
}).call(this);
