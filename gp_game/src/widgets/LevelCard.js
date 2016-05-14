// Generated by CoffeeScript 1.10.0

/*
  关卡卡牌
 */

(function() {
  this.LevelCard = cc.LayerColor.extend({
    mColor: null,
    mLevel: 1,
    mCallback: null,
    ctor: function(color, level) {
      this._super(color);
      this.mColor = color;
      this.mLevel = level;
      this.init();
      return this.addLevelCardLabel(level);
    },
    init: function() {
      var self;
      this.setContentSize(250, 114);
      this.ignoreAnchorPointForPosition(false);
      self = this;
      return TouchUtil.onClick(this, function() {
        return self.mCallback(self.mLevel);
      });
    },
    addLevelCardLabel: function(level) {
      var levelLabel;
      if (this.ring == null) {
        this.ring = new cc.Sprite(resImg.number_ring);
        this.addChild(this.ring, 0);
        levelLabel = new cc.LabelTTF(level.toString());
        levelLabel.attr({
          fontSize: 60,
          x: this.ring.width / 2,
          y: this.ring.height / 2
        });
        return this.ring.addChild(levelLabel, 0);
      }
    },
    addScoreLabel: function(score) {
      if (score == null) {
        score = "0";
      }
      this.label = new cc.LabelTTF(score);
      this.label.attr({
        fontSize: 40,
        x: this.width / 2,
        y: this.height / 2 - 10
      });
      return this.addChild(this.label, 0);
    },
    markLayer: function(isMark) {
      if (isMark) {
        if (this.mark == null) {
          this.mark = new cc.LayerColor(cc.color(69, 69, 69, 169));
          this.mark.setContentSize(this.getContentSize());
          this.addChild(this.mark, 10);
          return TouchUtil.onClick(this.mark, function() {
            return false;
          });
        } else {
          return this.mark.setLocalZOrder(10);
        }
      } else if (this.mark != null) {
        return this.mark.setLocalZOrder(-1);
      }
    },
    cardShake: function() {
      return this.shake = this.runAction(ActionManager.cardShake());
    },
    stopCardShake: function() {
      if (this.shake != null) {
        return this.stopAction(this.shake);
      }
    },
    openLevel: function(isOpen) {
      this.markLayer(!isOpen);
      if (isOpen) {
        this.stopCardShake();
        return this.ring.attr({
          scale: 0.5,
          anchorX: 0,
          anchorY: 1,
          x: 10,
          y: this.height - 10
        });
      } else {
        return this.ring.attr({
          scale: 1.0,
          anchorX: 0.5,
          anchorY: 0.5,
          x: this.width / 2,
          y: this.height / 2
        });
      }
    },
    nextOpenLevel: function() {
      this.openLevel(false);
      this.markLayer(false);
      return this.cardShake();
    },
    setOnClickCallback: function(callback) {
      return this.mCallback = callback;
    },
    setScore: function(score) {
      return this.addScoreLabel(score);
    }
  });

}).call(this);

//# sourceMappingURL=LevelCard.js.map