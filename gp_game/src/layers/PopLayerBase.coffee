###
  弹出框基类
###

@PopLayerBase = cc.Layer.extend

  mListener       :     null            # 事件对象
  mBgLayer        :     null            # 背景图层
  mMask           :     null            # 黑色遮罩层
  mIsPophidden    :     false           # 如果为真，则表示弹窗已经被关闭掉
  mIsTouchBgHide  :     true            # 如果为真，当点击黑色背景层的时候，弹窗会关掉. 默认为false,若为true，则存放弹窗的layer必须设置宽高
  mIsShowPopBegin :     true            # 弹窗一开始是否为可见,默认为true，如果为false，需手动调用show(cbFun)方法来显示
  mHiddenCallback       :     null            # 隐藏对话框回调函数
  mShowCallback        :     null            # 隐藏对话框回调函数

  ctor: () ->
    @_super()

    #初始化属性
    @setLocalZOrder(10000)
    @ignoreAnchorPointForPosition(false)
    @setContentSize(cc.winSize)
    @setPosition(cc.p(cc.winSize.width/2, cc.winSize.height/2))

    @visible = @mIsShowPopBegin

  #初始化黑色遮罩
  markLayer: (color)->
    if ccUtil.isObjectNotNull(color)
      @mMask = new cc.LayerColor(color)
      @addChild @mMask

  #添加事件，使弹窗下面的按钮无法点击
  # self 表示的是当前类的this
  addListener:  ->
    self = @
    @mListener = cc.EventListener.create({
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: (touch, event) ->
        if self.mIsTouchBgHide
          target = event.getCurrentTarget()  #获取事件所绑定的 target
          locationInNode = target.convertToNodeSpace touch.getLocation()
          s = target.getContentSize()
          rect = cc.rect(0, 0, s.width, s.height)
          if not cc.rectContainsPoint(rect, locationInNode)      #点击范围判断检测
            self.mIsPophidden = true
            self.hidden(self.mHiddenCallback)
            return false
          else
            return true
        else
          return true

      onTouchEnded: (touch, event) ->
        if self.mIsTouchBgHide and self.mIsPophidden
          self.deleteListener()
          self.mIsPophidden = false
          return false
    })
    cc.eventManager.addListener @mListener, @mBgLayer

  # 删除注册的监听事件
  deleteListener: ()->
    cc.eventManager.removeListener @mListener

  # 显示对话框
  show: (cbFun) ->
    # TODO 显示对话框动画待定
    self = @
    @visible = true
    if @mMask?
      fadeIn = new cc.FadeTo 0.2, 120
      @mMask.runAction fadeIn

    @mBgLayer.scale = 0
    scaleTo = new cc.ScaleTo(0.4, 1).easing(cc.easeElasticOut 0.7)
    func = ccUtil.callFunc(cbFun, "show dialog")
    seq = new cc.Sequence(scaleTo, func)
    @mBgLayer.runAction(seq)
    @addListener()

  # 隐藏对话框
  hidden: (cbFun)->
    # TODO 隐藏对话框动画待定
    self = @
    scaleTo = new cc.ScaleTo(0.4, 0).easing(cc.easeElasticOut 1.2)
    self = @
    fun = ->
      if ccUtil.isFunction(cbFun)
        cbFun()
      self.removeFromParent(true) # 动作完成后，移除自己
    func = ccUtil.callFunc(fun, "hidden dialog")
    seq = new cc.Sequence(scaleTo, func)
    @mBgLayer.runAction(seq)

    if @mMask?
      fadeOut = new cc.FadeOut 0.2
      @mMask.runAction fadeOut
#    @removeFromParent(true)

  setTouchbgHide : (flag) ->
    @mIsTouchBgHide = flag

  setHiddenCallback : (fun) ->
    @mHiddenCallback = fun
  setShowCallback : (fun) ->
    @mShowCallback = fun



