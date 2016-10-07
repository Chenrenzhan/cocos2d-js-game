// Generated by CoffeeScript 1.10.0
(function() {
  this.LevelLayer = cc.LayerColor.extend({
    mBigLevel: 0,
    mIsMark: false,
    mCurLevel: 0,
    ctor: function(color, bigLevel, isMark) {
      this._super(color);
      this.mCurLevel = DataUtil.getDataItem(Keys.CURRENT_LEVEL, 0);
      this.mBigLevel = bigLevel;
      this.mIsMark = isMark;
      this.addLevelTheme();
      this.addLevel();
      return this.markLayer(isMark);
    },
    addLevelTheme: function() {
      var theme;
      theme = new cc.LabelTTF(Configs.mStyle[this.mBigLevel]);
      theme.attr({
        fontSize: 50,
        anchorX: 0.5,
        anchorY: 1,
        x: cc.winSize.width / 2,
        y: 220
      });
      return this.addChild(theme, 0);
    },
    addLevel: function() {
      var i, j, label, level, results, self;
      results = [];
      for (i = j = 1; j <= 5; i = ++j) {
        level = this.mBigLevel * 5 + i;
        label = new cc.LabelTTF(level.toString());
        label.attr({
          fontSize: 60,
          anchorX: 0.5,
          anchorY: 0,
          opacity: 125,
          x: cc.winSize.width / 6 * i,
          y: 40
        });
        this.addChild(label, 0);
        jlog.i("@mCurLevel = " + this.mCurLevel);
        if (level <= (this.mCurLevel + 1)) {
          label.opacity = 255;
          self = this;
          results.push(TouchUtil.onClick(label, function(target) {
            var l;
            jlog.i("level = " + level + "    " + target.string);
            l = parseInt(target.string);
            return self.onStartGame(l);
          }));
        } else {
          results.push(void 0);
        }
      }
      return results;
    },
    markLayer: function(isMark) {
      this.mIsMark = isMark;
      isMark = false;
      if (isMark) {
        if (this.mark == null) {
          this.mark = new cc.LayerColor(cc.color(69, 69, 69, 120));
          this.mark.setContentSize(cc.winSize.width, 256);
          return this.addChild(this.mark, 10);
        } else {
          return this.mark.setLocalZOrder(10);
        }
      } else if (this.mark != null) {
        return this.mark.setLocalZOrder(-1);
      }
    },
    onStartGame: function(level) {
      var playScene;
      AudioManager.playStartGameAudio();
      playScene = new StartGameScene(level, 0);
      return cc.director.runScene(playScene);
    }
  });

}).call(this);

//# sourceMappingURL=LevelLayer.js.map
