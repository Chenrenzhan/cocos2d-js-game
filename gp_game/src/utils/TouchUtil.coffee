###
  触摸事件共计类
###

@TouchUtil =

  onClick : (targetNode, cbFunc)->
    listener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: true,
      onTouchBegan : (touch, event) ->
        target = event.getCurrentTarget()
        location = touch.getLocation()
        locationInNode = target.convertToNodeSpace(location) # 相对添加了目标节点的坐标
        s = target.getContentSize()
        rect = cc.rect(0, 0, s.width, s.height)
#        jlog.i "click began"
        if (cc.rectContainsPoint(rect, locationInNode))
#          jlog.i "click began inside"
          return true
        return false

      onTouchMoved : (touch, event) ->
        target = event.getCurrentTarget()

      onTouchEnded : (touch, event) ->
#        jlog.i "click end"
        target = event.getCurrentTarget()
        cbFunc(target)
#        ccUtil.callFunc(cbFunc, "模拟点击事件 ")

    cc.eventManager.addListener(listener, targetNode)

  cannotClick : (targetNode) ->
    listener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: true,
      onTouchBegan : (touch, event) ->
        jlog.i "kkkkkkkkkkkkkkkkkkkk"
        return true
      onTouchMoved : (touch, event) ->
        target = event.getCurrentTarget()

      onTouchEnded : (touch, event) ->

    cc.eventManager.addListener(listener, targetNode)