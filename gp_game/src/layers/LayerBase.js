// Generated by CoffeeScript 1.10.0

/*
  Layer基类
 */

(function() {
  this.LayerBase = cc.Layer.extend({
    mBgFrame: null,
    mIsBgTouch: false,
    mIsShowBgFrame: false,
    mIsAction: false,
    ctor: function() {
      var bgFrame, self, seq, sl, sl2;
      this._super();
      if (this.mIsShowBgFrame) {
        bgFrame = this.mBgFrame;
        if (bgFrame === null) {
          bgFrame = new cc.LayerColor(cc.color(0, 0, 0, 200));
        }
        this.addChild(bgFrame, 0);
        this.mBgFrame = bgFrame;
        this.setAnchorPoint(cc.p(0.5, 0.5));
      }
      this.ignoreAnchorPointForPosition(false);
      this.setContentSize(cc.winSize);
      this.setPosition(cc.p(cc.winSize.width / 2, cc.winSize.height / 2));
      if (this.mIsBgTouch) {
        cc.eventManager.addListener({
          event: cc.EventListener.TOUCH_ONE_BY_ONE,
          swallowTouches: true,
          onTouchBegan: function() {
            return true;
          }
        }, this);
      }
      if (this.mIsAction) {
        self = this;
        self.setScale(0.8);
        if (self !== null) {
          sl = cc.EaseIn.create(cc.ScaleTo.create(0.15, 1.1), 2);
          sl2 = cc.ScaleTo.create(0.15, 1);
          seq = cc.Sequence(sl, sl2);
          return self.runAction(seq);
        }
      }
    },
    setUIFile_File: function(file) {
      var json;
      json = ccs.load(file);
      return json.node;
    },
    setUIFile_JSON: function(file) {
      return ccs.uiReader.widgetFromJsonFile(file);
    },
    setBgColor: function(color) {
      return this.mBgFrame.setColor(color);
    },
    onEnter: function() {
      return this._super();
    },
    onExit: function() {
      return this._super();
    }
  });

}).call(this);

//# sourceMappingURL=LayerBase.js.map
