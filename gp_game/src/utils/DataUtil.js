// Generated by CoffeeScript 1.10.0

/*
  本地数据持久化工具类
 */

(function() {
  this.DataUtil = {
    mLS: cc.sys.localStorage,
    loadSettingsFile: function(callback) {
      return cc.loader.loadTxt(resJson.settings, function(err, data) {
        var key, obj, str;
        if (err) {
          jlog.e(err);
        }
        key = Keys.TEA_KEY;
        str = Base64.decode(XxTea.decrypt(Base64.decode(data), key));
        obj = JSON.parse(str);
        return callback(obj);
      });
    },
    setUserId: function(userId) {
      return this.mLS.setItem(Keys.USER_ID, userId);
    },
    getUserId: function() {
      var userId;
      userId = this.mLS.getItem(Keys.USER_ID);
      if (StringUtil.isEmpty(userId)) {
        userId = "nochannelid" + (new Date().getTime());
        this.setUserId(userId);
      }
      return userId;
    },
    getData: function() {
      var dataStr, jsonObj, jsonStr, obj;
      dataStr = this.mLS.getItem(Keys.DATA);
      if (StringUtil.isEmpty(dataStr)) {
        obj = new Object();
        obj[Keys.CHANNEL_ID] = "-1";
        obj[Keys.MUSIC] = true;
        obj[Keys.SOUND] = true;
        this.setData(obj);
        return obj;
      }
      jsonStr = Base64.decode(XxTea.decrypt(Base64.decode(dataStr), Keys.TEA_KEY));
      jsonObj = JSON.parse(jsonStr);
      return jsonObj;
    },
    setData: function(json) {
      var jsonStr;
      if (!StringUtil.isString(json)) {
        json = JSON.stringify(json);
      }
      jsonStr = Base64.encode(XxTea.encrypt(Base64.encode(json), Keys.TEA_KEY));
      return this.mLS.setItem(Keys.DATA, jsonStr);
    },
    saveData: function() {
      if (Configs.mData != null) {
        return this.setData(Configs.mData);
      }
    },
    saveLevelScore: function(level, score) {
      var data, i, j, ref, scores;
      if (Configs.mData == null) {
        return null;
      }
      data = Configs.mData;
      if (!ccUtil.isObjectNotNull(data[Keys.LEVEL_HIGHEST_SCORE])) {
        data[Keys.LEVEL_HIGHEST_SCORE] = [];
      }
      scores = data[Keys.LEVEL_HIGHEST_SCORE];
      if (scores.length < level) {
        for (i = j = 0, ref = level - scores.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          scores.push(0);
        }
      }
      if (scores[level - 1] < score) {
        scores[level - 1] = score;
      }
      if (level > data[Keys.CURRENT_LEVEL]) {
        data[Keys.CURRENT_LEVEL] = level;
      }
      return this.saveData();
    },
    saveMusicSettings: function(isOpen) {
      if (Configs.mData == null) {
        return null;
      }
      Configs.mData[Keys.MUSIC] = isOpen;
      return this.saveData();
    },
    saveSoundSettings: function(isOpen) {
      if (Configs.mData == null) {
        return null;
      }
      Configs.mData[Keys.SOUND] = isOpen;
      return this.saveData();
    },
    setDataItem: function(key, value) {
      if ((Configs.mData == null) || (key == null)) {
        return false;
      }
      Configs.mData[key] = value;
      return this.saveData();
    },
    getDataItem: function(key, defaultValue) {
      if (Configs.mData[key] == null) {
        Configs.mData[key] = defaultValue;
        this.saveData();
        return defaultValue;
      } else {
        return Configs.mData[key];
      }
    },
    refreshDataFromNet: function(userId) {
      var self;
      self = this;
      return BmobHelper.getLevelHighestScore(userId, function(scores) {
        if ((scores != null) && scores.length > 0) {
          Configs.mData[Keys.LEVEL_HIGHEST_SCORE] = scores;
          return self.saveData();
        }
      });
    }
  };

}).call(this);

//# sourceMappingURL=DataUtil.js.map
