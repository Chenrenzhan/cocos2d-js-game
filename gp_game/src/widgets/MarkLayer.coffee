###
  遮罩层
###

@MarkLayer = cc.LayerColor.extend

  ctor: (color) ->
    @_super(color)

    @onListener()

  #添加事件，使弹窗下面的按钮无法点击
  # self 表示的是当前类的this
  onListener :  ->
    self = @
    listener = cc.EventListener.create({
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: (touch, event) ->
        return true
      onTouchEnded: (touch, event) ->
    })
    cc.eventManager.addListener(listener, @)
