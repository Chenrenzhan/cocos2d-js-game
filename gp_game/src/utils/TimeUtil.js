// Generated by CoffeeScript 1.10.0

/*
  处理时间，时间格式转换等工具类
 */

(function() {
  this.TimeUtil = {
    getTimeStamp: function() {
      return new Date().getTime();
    },

    /*
      开始计时
     */
    startTimer: function(interval, cbFunc) {
      var err, error;
      try {
        clearInterval(interval);
      } catch (error) {
        err = error;
        jlog.cc(err);
      }
      interval = setInterval(cbFunc, 1000);
      return interval;
    }
  };

}).call(this);

//# sourceMappingURL=TimeUtil.js.map