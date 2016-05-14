// Generated by CoffeeScript 1.10.0

/*
  触摸事件共计类
 */

(function() {
  this.TouchUtil = {
    onClick: function(targetNode, cbFunc) {
      var listener;
      listener = cc.EventListener.create({
        event: cc.EventListener.TOUCH_ONE_BY_ONE,
        swallowTouches: true,
        onTouchBegan: function(touch, event) {
          var location, locationInNode, rect, s, target;
          target = event.getCurrentTarget();
          location = touch.getLocation();
          locationInNode = target.convertToNodeSpace(location);
          s = target.getContentSize();
          rect = cc.rect(0, 0, s.width, s.height);
          if (cc.rectContainsPoint(rect, locationInNode)) {
            return true;
          }
          return false;
        },
        onTouchMoved: function(touch, event) {
          var target;
          return target = event.getCurrentTarget();
        },
        onTouchEnded: function(touch, event) {
          return cbFunc();
        }
      });
      return cc.eventManager.addListener(listener, targetNode);
    },
    cannotClick: function(targetNode) {
      var listener;
      listener = cc.EventListener.create({
        event: cc.EventListener.TOUCH_ONE_BY_ONE,
        swallowTouches: true,
        onTouchBegan: function(touch, event) {
          return true;
        },
        onTouchMoved: function(touch, event) {
          var target;
          return target = event.getCurrentTarget();
        },
        onTouchEnded: function(touch, event) {}
      });
      return cc.eventManager.addListener(listener, targetNode);
    }
  };

}).call(this);

//# sourceMappingURL=TouchUtil.js.map
