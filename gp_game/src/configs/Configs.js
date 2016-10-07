// Generated by CoffeeScript 1.10.0

/*
  属性配置工具类
 */

(function() {
  var _Configs;

  _Configs = cc.Class.extend({
    mAndroidPackageName: "org/cocos2dx/gp_game",
    mIsBgmPlay: true,
    mLoadResourceDelay: 0.5,
    mSettings: null,
    mLocalData: null,
    mUserId: null,
    mColors: [cc.color(253, 61, 83), cc.color(252, 200, 186), cc.color(241, 30, 105), cc.color(250, 163, 167), cc.color(251, 140, 138), cc.color(219, 27, 81)],
    mColorSum: 6,
    mCellSumMax: 9,
    mCellSumX: 9,
    mCellSumY: 9,
    mCellImgWidth: 100,
    mCellWidth: 0,
    mCellScale: 0,
    mCellGap: 0,
    mBorderX: 0,
    mBorderY: 0,
    mStyle: ["Joy", "Sweet", "Romantic", "Meek", "Elegant"],
    ctor: function() {
      if (ccUtil.isNative()) {
        cc.view.setDesignResolutionSize(720, 1280, cc.ResolutionPolicy.EXACT_FIT);
      } else {
        cc.view.setDesignResolutionSize(720, 1280, cc.ResolutionPolicy.SHOW_ALL);
      }
      this.mCellWidth = cc.winSize.width / this.mCellSumMax;
      this.mCellScale = this.mCellWidth / this.mCellImgWidth;
      this.setCellSum(this.mCellSumX, this.mCellSumY);
      DataUtil.loadSettingsFile((function(_this) {
        return function(jsonObj) {
          return _this.mSettings = jsonObj;
        };
      })(this));
      this.mUserId = DataUtil.getUserId();
      Keys.DATA = this.mUserId;
      this.mData = DataUtil.getData();
      this.mIsBgmPlay = this.mData[Keys.MUSIC];
      jlog.cc(this.mData);
      jlog.cc(this.mUserId);
      BmobHelper.addUser(this.mUserId, this.mData[Keys.CHANNEL_ID]);
      DataUtil.refreshDataFromNet(this.mUserId);
      if (ccUtil.isNative()) {
        return umeng.MobClickCpp.profileSignIn(this.mUserId, this.mData[Keys.CHANNEL_ID]);
      }
    },
    setCellSum: function(sumX, sumY) {
      this.mCellSumX = sumX;
      return this.mCellSumY = sumY;
    },
    setColors: function(level) {
      var c, color, colors, i, len, results;
      level -= 1;
      colors = this.mSettings[Keys.LEVELS][Math.floor(level / 5)][Keys.COLORS];
      this.mColors = null;
      this.mColors = [];
      results = [];
      for (i = 0, len = colors.length; i < len; i++) {
        c = colors[i];
        color = cc.color(c.r, c.g, c.b, c.a);
        results.push(this.mColors.push(color));
      }
      return results;
    }
  });

  this.Configs = new _Configs();

}).call(this);

//# sourceMappingURL=Configs.js.map
