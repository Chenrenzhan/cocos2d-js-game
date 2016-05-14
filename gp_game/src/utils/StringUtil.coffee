###
  处理字符串
###

@StringUtil =

  toString : (object) ->
    str = ""
    try
      str = JSON.stringify(object)
    catch
      str = "Object[Object]"
    finally
      return str

  # 判断字符串为空
  isEmpty : (str) ->
    if (str isnt null) and (str isnt undefined) and (str isnt "")
      return false
    else
      return true

  # 判断是否为字符串
  isString : (json) ->
    return Object.prototype.toString.call(json) is "[object String]"

