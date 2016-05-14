###
  打印log日志工具类
###

# TAG用于打印出来进行筛选
@jlog =
  staticClass :   true              # 静态类
  TAG_ERROR   :   "cocos-error"     # 错误
  TAG_WARM    :   "cocos-warn"      # 提醒,警告
  TAG_INFO    :   "cocos-info"
  TAG_DEBUG   :   "cocos-debug"
  TAG_VERBOSE :   "cocos-verbose"
  TAG_THROW   :   "cocos-throw"     # 抛出异常打印

  e : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_ERROR}  :  #{logMsg}"

  w : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_WARM}  :  #{logMsg}"

  i : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_INFO}  :  #{logMsg}"

  d : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_DEBUG}  :  #{logMsg}"

  v : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_VERBOSE}  :  #{logMsg}"

  t : (logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{@TAG_THROW}  :  #{logMsg}"

  c : (tag, logMsg) ->
    if OnOff.isLogOpen
      logMsg = StringUtil.toString logMsg
      cc.log "#{tag}  :  #{logMsg}"

  cc : (logMsg) ->
    if OnOff.isLogOpen
      cc.log logMsg
