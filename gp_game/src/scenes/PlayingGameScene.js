// Generated by CoffeeScript 1.10.0

/*
  玩游戏场景
 */

(function() {
  var PlayingGameLayer;

  PlayingGameLayer = LayerBase.extend({
    mBgLayerColor: null,
    mChessboard: null,
    mStepLabel: null,
    mGoalColorIndex: 0,
    mScore: 0,
    mScoreLabel: null,
    mTimeLabel: null,
    mInterval: null,
    mGoalScoreLabel: null,
    mLevelLabel: null,
    mCurLevel: 1,
    mBtnOption: null,
    mLabelRightX: cc.winSize.width,
    mLevelTitleLabel: null,
    mStepTitleLabel: null,
    mTimeTitleLabel: null,
    mScoreTitleLabel: null,
    mGoalScoreLabel: null,
    mBtnOption: null,
    mMaskLayer: null,
    mOverDialog: null,
    mPauseDialog: null,
    mHadWin: false,
    mHadFails: false,
    mBtnMagicWand: null,
    mBtnBackStep: null,
    mBtnAddStep: null,
    ctor: function(level) {
      this._super();
      this.mCurLevel = level;
      this.addBgLayerColor();
      this.addChessboardView();
      this.addOperateBtn();
      this.addBtnMagicWand();
      this.addBtnBackStep();
      this.addBtnAddStep();
      this.addLevelLabel();
      this.addScoreLabel();
      return this.onGameStart(this.mCurLevel);
    },
    addBgLayerColor: function() {
      this.mBgLayerColor = new cc.LayerColor(Configs.mColors[0]);
      return this.addChild(this.mBgLayerColor);
    },
    addChessboardView: function() {
      this.mChessboard = new ChessboardView();
      this.mChessboard.attr({
        anchorX: 0.5,
        anchorY: 0,
        x: cc.winSize.width / 2,
        y: 200
      });
      this.addChild(this.mChessboard, 0);
      this.mChessboard.setOnColorChange(this.onColorChange());
      this.mChessboard.setOnStepChange(this.onStepChange());
      return this.mChessboard.setOnScoreChange(this.onScoreChange());
    },
    addOperateBtn: function() {
      var menuItem, pauseImg, restartImg, self;
      pauseImg = new cc.MenuItemImage(resImg.pause);
      restartImg = new cc.MenuItemImage(resImg.restart);
      self = this;
      menuItem = new cc.MenuItemToggle(pauseImg, restartImg, function(sender) {
        AudioManager.playClickAudio();
        jlog.cc(sender.getSelectedIndex());
        if (sender.getSelectedIndex() === 0) {
          return self.onStart();
        } else if (sender.getSelectedIndex() === 1) {
          return self.onPause(menuItem);
        }
      }, this);
      this.mBtnOption = new cc.Menu(menuItem);
      this.mBtnOption.attr({
        anchorX: 0,
        anchorY: 1,
        x: 65 + pauseImg.width / 2,
        y: cc.winSize.height - pauseImg.height / 2 - 50
      });
      return this.addChild(this.mBtnOption);
    },
    onStart: function() {
      if (this.mMaskLayer != null) {
        this.mMaskLayer.removeFromParent(true);
        this.mMaskLayer = null;
        this.mBtnOption.setLocalZOrder(0);
      }
      if (this.mPauseDialog != null) {
        return this.mPauseDialog.hidden();
      }
    },
    onPause: function(menuItem) {
      var self;
      this.mBtnOption.setLocalZOrder(15);
      this.mMaskLayer = new MarkLayer(cc.color(0, 0, 0, 150));
      this.mMaskLayer.attr({
        anchorX: 0,
        anchorY: 0,
        width: cc.winSize.width,
        height: 200 + this.mChessboard.height,
        x: 0,
        y: 0
      });
      this.addChild(this.mMaskLayer, 10);
      this.mPauseDialog = new PauseDialog();
      self = this;
      this.mPauseDialog.setReplayCb(function() {
        jlog.i("重玩游戏回调");
        self.onGameStart(self.mCurLevel);
        self.mMaskLayer.removeFromParent(true);
        self.mMaskLayer = null;
        self.mBtnOption.setLocalZOrder(0);
        return menuItem.setSelectedIndex(0);
      });
      return this.addChild(this.mPauseDialog, 10);
    },
    addBtnMagicWand: function() {
      var self;
      this.mBtnMagicWand = new ccui.Button();
      this.mBtnMagicWand.loadTextureNormal(resImg.magic_wand, ccui.Widget.LOCAL_TEXTURE);
      this.mBtnMagicWand.setPressedActionEnabled(true);
      this.mBtnMagicWand.attr({
        anchorY: 0,
        x: cc.winSize.width / 4,
        y: 70
      });
      this.mBtnMagicWand.setTouchEnabled(true);
      this.addChild(this.mBtnMagicWand, 5);
      self = this;
      this.mChessboard.setReleaseMagicCb(function() {
        return self.mBtnMagicWand.scale = 1.0;
      });
      return this.mBtnMagicWand.addTouchEventListener(function(touch, event) {
        if (event === ccui.Widget.TOUCH_ENDED) {
          AudioManager.playClickAudio();
          jlog.i("魔术棒点击回调");
          self.mChessboard.selectMagic();
          return self.mBtnMagicWand.scale = 1.5;
        }
      }, this.mBtnMagicWand);
    },
    addBtnBackStep: function() {
      var self;
      this.mBtnBackStep = new ccui.Button();
      this.mBtnBackStep.loadTextureNormal(resImg.back_step, ccui.Widget.LOCAL_TEXTURE);
      this.mBtnBackStep.setPressedActionEnabled(true);
      this.mBtnBackStep.attr({
        anchorY: 0,
        x: cc.winSize.width / 4 * 2,
        y: 70
      });
      this.mBtnBackStep.setTouchEnabled(true);
      self = this;
      this.addChild(this.mBtnBackStep, 5);
      return this.mBtnBackStep.addTouchEventListener(function(touch, event) {
        if (event === ccui.Widget.TOUCH_ENDED) {
          AudioManager.playClickAudio();
          jlog.i("返回1步点击回调");
          return self.onBackOneStep();
        }
      }, this.mBtnBackStep);
    },
    addBtnAddStep: function() {
      var self;
      this.mBtnAddStep = new ccui.Button();
      this.mBtnAddStep.loadTextureNormal(resImg.add_5_step, ccui.Widget.LOCAL_TEXTURE);
      this.mBtnAddStep.setPressedActionEnabled(true);
      this.mBtnAddStep.attr({
        anchorY: 0,
        x: cc.winSize.width / 4 * 3,
        y: 70
      });
      this.mBtnAddStep.setTouchEnabled(true);
      self = this;
      this.addChild(this.mBtnAddStep, 5);
      return this.mBtnAddStep.addTouchEventListener(function(touch, event) {
        if (event === ccui.Widget.TOUCH_ENDED) {
          AudioManager.playClickAudio();
          jlog.i("增加5步点击回调");
          self.setStepSum(5);
          if (ccUtil.isNative()) {
            return umeng.MobClickCpp.use("props-2", 1, 3);
          }
        }
      }, this.mBtnAddStep);
    },
    addLevelLabel: function() {
      this.mLevelTitleLabel = new cc.LabelTTF("关卡数");
      this.mLevelTitleLabel.fontSize = 25;
      this.mLevelTitleLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mLevelTitleLabel.attr({
        anchorX: 1,
        anchorY: 1,
        x: cc.winSize.width - 65,
        y: cc.winSize.height - 50
      });
      this.addChild(this.mLevelTitleLabel, 0);
      this.mLabelRightX = this.mLevelTitleLabel.x - this.mLevelTitleLabel.width;
      this.mLevelLabel = new cc.LabelTTF(this.mCurLevel);
      this.mLevelLabel.fontSize = 25;
      this.mLevelLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mLevelLabel.attr({
        x: this.mLevelTitleLabel.x - this.mLevelTitleLabel.width / 2,
        y: this.mLevelTitleLabel.y - this.mLevelTitleLabel.height - 20
      });
      return this.addChild(this.mLevelLabel, 0);
    },
    addStepLabel: function() {
      this.mStepTitleLabel = new cc.LabelTTF("剩余步数");
      this.mStepTitleLabel.fontSize = 25;
      this.mStepTitleLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mStepTitleLabel.attr({
        anchorX: 1,
        anchorY: 1,
        x: this.mLabelRightX - 20,
        y: cc.winSize.height - 50
      });
      this.addChild(this.mStepTitleLabel, 0);
      this.mLabelRightX = this.mStepTitleLabel.x - this.mStepTitleLabel.width;
      this.mStepLabel = new cc.LabelTTF("0");
      this.mStepLabel.fontSize = 25;
      this.mStepLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mStepLabel.attr({
        x: this.mStepTitleLabel.x - this.mStepTitleLabel.width / 2,
        y: this.mStepTitleLabel.y - this.mStepTitleLabel.height - 20
      });
      return this.addChild(this.mStepLabel, 0);
    },
    setStepLabelVisible: function(isVisible) {
      if (isVisible && (this.mStepTitleLabel == null)) {
        return this.addStepLabel();
      } else if (!isVisible && (this.mStepTitleLabel != null)) {
        this.mStepTitleLabel.removeFromParent(false);
        return this.mStepLabel.removeFromParent(false);
      }
    },
    addTimeLabel: function() {
      this.mTimeTitleLabel = new cc.LabelTTF("剩余时间");
      this.mTimeTitleLabel.fontSize = 25;
      this.mTimeTitleLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mTimeTitleLabel.attr({
        anchorX: 1,
        anchorY: 1,
        x: this.mLabelRightX - 20,
        y: cc.winSize.height - 50
      });
      this.addChild(this.mTimeTitleLabel, 0);
      this.mLabelRightX = this.mTimeTitleLabel.x - this.mTimeTitleLabel.width;
      this.mTimeLabel = new cc.LabelTTF(StringUtil.toString(0));
      this.mTimeLabel.fontSize = 25;
      this.mTimeLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mTimeLabel.attr({
        x: this.mTimeTitleLabel.x - this.mTimeTitleLabel.width / 2,
        y: this.mTimeTitleLabel.y - this.mTimeTitleLabel.height - 20
      });
      return this.addChild(this.mTimeLabel, 0);
    },
    setTimeLabelVisible: function(isVisible) {
      if (isVisible && (this.mTimeTitleLabel == null)) {
        return this.addTimeLabel();
      } else if (!isVisible && (this.mTimeTitleLabel != null)) {
        this.mTimeTitleLabel.removeFromParent(false);
        return this.mTimeLabel.removeFromParent(false);
      }
    },
    addGoalScoreLabel: function() {
      this.mScoreTitleLabel = new cc.LabelTTF("目标分数");
      this.mScoreTitleLabel.fontSize = 25;
      this.mScoreTitleLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mScoreTitleLabel.attr({
        anchorX: 1,
        anchorY: 1,
        x: this.mLabelRightX - 20,
        y: cc.winSize.height - 50
      });
      this.addChild(this.mScoreTitleLabel, 0);
      this.mLabelRightX = this.mScoreTitleLabel.x - this.mScoreTitleLabel.width;
      this.mGoalScoreLabel = new cc.LabelTTF(StringUtil.toString(0));
      this.mGoalScoreLabel.fontSize = 25;
      this.mGoalScoreLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mGoalScoreLabel.attr({
        x: this.mScoreTitleLabel.x - this.mScoreTitleLabel.width / 2,
        y: this.mScoreTitleLabel.y - this.mScoreTitleLabel.height - 20
      });
      return this.addChild(this.mGoalScoreLabel, 0);
    },
    setScoreLabelVisible: function(isVisible) {
      if (isVisible && (this.mScoreTitleLabel == null)) {
        return this.addGoalScoreLabel();
      } else if (!isVisible && (this.mScoreTitleLabel != null)) {
        this.mScoreTitleLabel.removeFromParent(false);
        return this.mGoalScoreLabel.removeFromParent(false);
      }
    },
    addScoreLabel: function() {
      this.mScoreLabel = new cc.LabelTTF("17305");
      this.mScoreLabel.fontSize = 100;
      this.mScoreLabel.fillStyle = cc.color(255, 255, 255, 255);
      this.mScoreLabel.attr({
        anchorX: 0,
        anchorY: 1,
        x: 65,
        y: cc.winSize.height - 180
      });
      return this.addChild(this.mScoreLabel, 0);
    },
    setGoalColor: function() {
      this.mGoalColorIndex = 0;
      this.mChessboard.mGoalColorIndex = this.mGoalColorIndex;
      return this.mBgLayerColor.setColor(Configs.mColors[this.mGoalColorIndex]);
    },
    onGameStart: function(level) {
      var self;
      if (ccUtil.isNative()) {
        umeng.MobClickCpp.startLevel("level-" + level);
      }
      self = this;
      this.initGameParam(level);
      this.setGoalColor();
      return this.mChessboard.resetChess();
    },
    initGameParam: function(level) {
      var goalColorSum, limitScore, limitStep, limitTime, self;
      this.mHadFails = false;
      this.mHadWin = false;
      this.mScore = 0;
      this.mLevelLabel.setString(level);
      this.mScoreLabel.setString('0');
      level = level % 50;
      this.mCurLevel = level;
      Configs.setColors(level);
      goalColorSum = GameUtil.getGoalColorSum(level);
      this.mChessboard.setGoalColorSum(goalColorSum);
      limitStep = GameUtil.getLimitStep(level);
      if (limitStep === false) {
        this.setStepLabelVisible(false);
      } else {
        this.setStepLabelVisible(true);
        this.mStepLabel.setString(limitStep.toString());
        this.mChessboard.setStepSum(limitStep);
      }
      limitTime = GameUtil.getLimitTime(level);
      if (limitTime === false) {
        this.setTimeLabelVisible(false);
      } else {
        this.setTimeLabelVisible(true);
        this.mTimeLabel.setString(limitTime.toString());
        self = this;
        this.mInterval = TimeUtil.startTimer(self.mInterval, function() {
          var t;
          t = parseInt(self.mTimeLabel.string);
          t--;
          self.mTimeLabel.string = t.toString();
          if (t <= 0) {
            self.onGameFails();
            return clearInterval(self.mInterval);
          }
        });
      }
      limitScore = GameUtil.getLimitScore(level);
      if (limitScore === false) {
        return this.setScoreLabelVisible(false);
      } else {
        this.setScoreLabelVisible(true);
        return this.mGoalScoreLabel.setString(limitScore.toString());
      }
    },
    onColorChange: function() {
      var self;
      self = this;
      return function(curGoalColorSum) {
        if (curGoalColorSum >= (Configs.mCellSumX * Configs.mCellSumY)) {
          if (GameUtil.getLimitScore(self.mCurLevel) === false) {
            return self.onGameWin();
          } else {
            if (GameUtil.getLimitScore(self.mCurLevel) > self.mScore) {
              return self.onGameFails();
            } else {
              return self.onGameWin();
            }
          }
        }
      };
    },
    onStepChange: function() {
      var self;
      self = this;
      return function(step) {
        return self.setStep(step);
      };
    },
    onScoreChange: function() {
      var self;
      self = this;
      return function(score) {
        return self.setScore(score);
      };
    },
    setStep: function(step) {
      var sum;
      if (GameUtil.getLimitStep(this.mCurLevel) === false) {
        return;
      }
      sum = GameUtil.getLimitStep(this.mCurLevel);
      this.mStepLabel.string = step;
      if (step <= 0) {
        return this.onGameFails();
      }
    },
    reduceStep: function() {
      var step;
      if (GameUtil.getLimitStep(this.mCurLevel) === false) {
        return;
      }
      step = this.mStepLabel.string;
      step = parseInt(step);
      step--;
      this.mStepLabel.string = step;
      if (step <= 0) {
        return this.onGameFails();
      }
    },
    setStepSum: function(stepSum) {
      var step;
      if (GameUtil.getLimitStep(this.mCurLevel) === false) {
        return;
      }
      step = this.mStepLabel.string;
      step = parseInt(step);
      step += stepSum;
      this.mStepLabel.string = step;
      return this.mChessboard.setStepSum(step);
    },
    onBackOneStep: function() {
      if (this.mChessboard.mSwapCells.length > 0) {
        return this.mChessboard.backOneStep();
      } else {
        return jlog.i("不可回退");
      }
    },
    setScore: function(score) {
      this.mScoreLabel.string = score;
      return this.mScore = score;
    },
    onGameFails: function() {
      var self;
      self = this;
      if (this.mHasWin || this.mHadFails) {
        return;
      }
      this.mHadFails = true;
      AudioManager.playFailsAudio();
      if (ccUtil.isNative()) {
        umeng.MobClickCpp.failLevel("level-" + this.mCurLevel);
      }
      BmobHelper.saveGameFail(Configs.mUserId, this.mCurLevel, this.mScore);
      return this.onGameOver(this.mCurLevel, 2, this.mScore);
    },
    onGameWin: function() {
      if (this.mHadFails || this.mHasWin) {
        return;
      }
      this.mHasWin = true;
      AudioManager.playWinAudio();
      if (ccUtil.isNative()) {
        umeng.MobClickCpp.finishLevel("level-" + this.mCurLevel);
      }
      DataUtil.saveLevelScore(this.mCurLevel, this.mScore);
      BmobHelper.saveGameWin(Configs.mUserId, this.mCurLevel, this.mScore);
      jlog.i("@mScore = " + this.mScore);
      return this.onGameOver(this.mCurLevel, 1, this.mScore);
    },
    replayThisLevel: function() {
      return this.onGameStart(this.mCurLevel);
    },
    nextLevel: function() {
      this.mCurLevel++;
      return this.onGameStart(this.mCurLevel);
    },
    onGameOver: function(level, type, score) {
      var playScene;
      playScene = new StartGameScene(level, type, score);
      return cc.director.runScene(playScene);
    },
    back: function() {
      return cc.director.runScene(new MainScene1());
    }
  });

  this.PlayingGameScene = cc.Scene.extend({
    mLevel: 1,
    ctor: function(level) {
      this._super();
      return this.mLevel = level;
    },
    onEnter: function() {
      var layer;
      this._super();
      layer = new PlayingGameLayer(this.mLevel);
      this.addChild(layer);
      return AudioManager.initBgm();
    },
    onExit: function() {
      return AudioManager.stopBgm();
    }
  });

}).call(this);

//# sourceMappingURL=PlayingGameScene.js.map
