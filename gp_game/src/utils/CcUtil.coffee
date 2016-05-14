###
  封装Cocos API以方便调用
###

@ccUtil =
  # 动画Action的动作完成之后回调
  callFunc : (cbFunc, msg) ->
    msg = "" if not msg?
#    return new cc.CallFunc (e)->
    if( typeof cbFunc isnt "undefined" and typeof cbFunc is "function")
      return new cc.CallFunc(cbFunc)
    else
      return new cc.CallFunc( ->
        jlog.t "#{msg} callback function is undefine or not a function "
      )

  isAndroid : ->
    return cc.sys.os is cc.sys.OS_ANDROID

  isIOS : ->
    return cc.sys.os is cc.sys.OS_IOS

  isNative : ->
    return cc.sys.isNative

  isMobile : ->
    return cc.sys.isMobile

  # 判断是否为function
  isFunction : (func) ->
    if( typeof func isnt undefined and typeof func is "function")
      return true
    else
      jlog.t "function is undefine or not a function "
      return false

  # 判断一对对象是否为空
  isObjectNotNull : (obj) ->
    if (obj isnt null) and (obj isnt undefined)
      return true
    else
      return false


