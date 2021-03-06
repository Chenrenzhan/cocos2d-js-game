// Generated by CoffeeScript 1.10.0

/*
  加载资源显示的layer
 */

(function() {
  this.LoadingLayer = LayerBase.extend({
    mLogoSprite: null,
    mTipSprite: null,
    mloadingProgressLabel: null,
    ctor: function() {
      this._super();
      this.addBg();
      this.addLogo();
      this.addTip();
      return this.addLoadingLabel();
    },
    addBg: function() {
      if (this.mBgFrame !== null) {
        this.mBgFrame.removeFromParent(false);
      }
      this.mBgFrame = new cc.LayerColor(cc.color(255, 255, 255, 255));
      return this.addChild(this.mBgFrame);
    },
    addLogo: function() {
      this.mLogoSprite = new cc.Sprite(resImg.logo);
      this.mLogoSprite.attr({
        x: cc.winSize.width / 2,
        y: cc.winSize.height / 2
      });
      return this.addChild(this.mLogoSprite);
    },
    addTip: function() {
      this.mTipSprite = new cc.Sprite(resImg.loading_tip);
      this.mTipSprite.attr({
        x: cc.winSize.width / 2 + 125,
        y: cc.winSize.height / 2 + 80
      });
      this.addChild(this.mTipSprite);
      return this.mTipSprite.runAction(ActionManager.rotateAction());
    },
    addLoadingLabel: function() {
      var label;
      label = new cc.LabelTTF("正在拼命加载...");
      label.fontSize = 30;
      label.fillStyle = cc.color(0, 0, 0, 255);
      label.attr({
        x: cc.winSize.width / 2 - 30,
        y: this.mLogoSprite.y - 150
      });
      this.addChild(label);
      this.mloadingProgressLabel = new cc.LabelTTF("0%");
      this.mloadingProgressLabel.fontSize = 30;
      this.mloadingProgressLabel.fillStyle = cc.color(0, 0, 0, 255);
      this.mloadingProgressLabel.attr({
        x: label.x + label.width / 2 + 30,
        y: label.y
      });
      return this.addChild(this.mloadingProgressLabel);
    },
    setPercent: function(percent) {
      return this.mloadingProgressLabel.string = percent + "%";
    }
  });

}).call(this);

//# sourceMappingURL=LoadingLayer.js.map
