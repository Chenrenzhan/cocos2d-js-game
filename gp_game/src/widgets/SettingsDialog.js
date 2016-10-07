// Generated by CoffeeScript 1.10.0

/*
  设置对话框
 */

(function() {
  this.SettingsDialog = PopLayerBase.extend({
    mBgLayer: null,
    mBtnClose: null,
    mMusic: null,
    mSound: null,
    mCloseCallback: null,
    ctor: function() {
      this._super();
      this.setTouchbgHide(false);
      this.addBgLayer();
      this.addCloseBtn();
      this.addMusic();
      return this.addSound();
    },
    addBgLayer: function() {
      this.mBgLayer = new cc.LayerColor(cc.color(255, 255, 255, 255));
      this.mBgLayer.ignoreAnchorPointForPosition(false);
      this.mBgLayer.setContentSize(400, 300);
      this.mBgLayer.attr({
        x: cc.winSize.width / 2,
        y: cc.winSize.height / 2
      });
      this.addChild(this.mBgLayer);
      return TouchUtil.cannotClick(this.mBgLayer);
    },
    addCloseBtn: function() {
      var self;
      this.mBtnClose = new ccui.Button();
      this.mBtnClose.loadTextureNormal(resImg.close, ccui.Widget.LOCAL_TEXTURE);
      this.mBtnClose.setPressedActionEnabled(true);
      this.mBtnClose.attr({
        x: this.mBgLayer.width - 30,
        y: this.mBgLayer.height - 30
      });
      this.mBtnClose.setTouchEnabled(true);
      this.mBgLayer.addChild(this.mBtnClose, 5);
      self = this;
      return this.mBtnClose.addTouchEventListener(function(touch, event) {
        if (event === ccui.Widget.TOUCH_ENDED) {
          return self.hidden(self.mCloseCallback);
        }
      }, this.mBtnClose);
    },
    addMusic: function() {
      var index, label;
      label = new cc.LabelTTF("音乐");
      label.attr({
        fillStyle: cc.color(0, 0, 0, 255),
        fontSize: 40,
        anchorX: 0,
        anchorY: 0.5,
        x: 50,
        y: 180
      });
      this.mBgLayer.addChild(label);
      index = Configs.mData[Keys.MUSIC] ? 0 : 1;
      this.mMusic = this.createToggle(index, function() {
        jlog.i("打开音乐");
        return AudioManager.saveIsBgmPlay(true);
      }, function() {
        jlog.i("关闭音乐");
        AudioManager.stopBgm();
        return AudioManager.saveIsBgmPlay(false);
      });
      this.mMusic.attr({
        anchorX: 1,
        anchorY: 0.5,
        x: this.mBgLayer.width - 100,
        y: label.y
      });
      return this.mBgLayer.addChild(this.mMusic, 5);
    },
    addSound: function() {
      var index, label;
      label = new cc.LabelTTF("音效");
      label.attr({
        fillStyle: cc.color(0, 0, 0, 255),
        fontSize: 40,
        anchorX: 0,
        anchorY: 0.5,
        x: 50,
        y: 90
      });
      this.mBgLayer.addChild(label);
      index = Configs.mData[Keys.SOUND] ? 0 : 1;
      this.mSound = this.createToggle(index, function() {
        return AudioManager.saveIsSound(true);
      }, function() {
        return AudioManager.saveIsSound(false);
      });
      this.mSound.attr({
        anchorX: 1,
        anchorY: 0.5,
        x: this.mBgLayer.width - 100,
        y: label.y
      });
      return this.mBgLayer.addChild(this.mSound, 5);
    },
    createToggle: function(selectIndex, noCallback, offCallback) {
      var menu, menuItem, self, toggleNo, toggleOff;
      toggleNo = new cc.MenuItemImage(resImg.toggle_no);
      toggleOff = new cc.MenuItemImage(resImg.toggle_off);
      self = this;
      menuItem = new cc.MenuItemToggle(toggleNo, toggleOff, function(sender) {
        AudioManager.playClickAudio();
        if (sender.getSelectedIndex() === 0) {
          return noCallback();
        } else if (sender.getSelectedIndex() === 1) {
          return offCallback();
        }
      }, this);
      menuItem.setSelectedIndex(selectIndex);
      menu = new cc.Menu(menuItem);
      return menu;
    },
    setHiddenCallback: function(fun) {
      return this.mCloseCallback = fun;
    }
  });

}).call(this);

//# sourceMappingURL=SettingsDialog.js.map
