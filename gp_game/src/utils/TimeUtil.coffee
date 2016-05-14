###
  处理时间，时间格式转换等工具类
###

@TimeUtil =

  # 获取当前时间戳
  getTimeStamp : ->
    return new Date().getTime()

  ###
    开始计时
  ###
  startTimer : (interval, cbFunc) ->
    try
      clearInterval(interval);
    catch err
      jlog.cc err
    interval = setInterval(cbFunc, 1000)
    return interval
    