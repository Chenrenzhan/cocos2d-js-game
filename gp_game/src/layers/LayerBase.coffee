###
  Layer基类
###
@LayerBase = cc.Layer.extend
  mBgFrame        :     null    # 背景图层
  mIsBgTouch      :     false   # 底层及底层以下是否可触摸响应
  mIsShowBgFrame  :     false   # 是否显示底层背景图层
  mIsAction       :     false   # 打开关闭是否带特效动画

  ctor: ->
    @_super()

    #渲染一个背景层，默认为黑色的半透明的
    if @mIsShowBgFrame
      # 背景
      bgFrame = @mBgFrame
      if bgFrame is null
        bgFrame = new cc.LayerColor(cc.color(0, 0, 0, 200))
      @addChild(bgFrame, 0)
      @mBgFrame = bgFrame
      @setAnchorPoint(cc.p(0.5, 0.5))

    #设置当前层里面所有节点的描点也和该层相同
    @ignoreAnchorPointForPosition(false)
    @setContentSize(cc.winSize)
    @setPosition(cc.p(cc.winSize.width/2, cc.winSize.height/2))

    #开启底层不可点击触摸（层以下的UI都不可被点击）
    if @mIsBgTouch
      #点击事件
      cc.eventManager.addListener
        event: cc.EventListener.TOUCH_ONE_BY_ONE,
        swallowTouches: true,
        onTouchBegan: ->
          return true
      , @

    #开启打开窗体是带的特效
    if @mIsAction
      # TODO 打开动画待定
      self = this
      self.setScale(0.8)
      if self isnt null
        sl = cc.EaseIn.create cc.ScaleTo.create(0.15,1.1), 2
        sl2 = cc.ScaleTo.create 0.15,1
        seq = cc.Sequence sl,sl2
        self.runAction seq

  setUIFile_File : (file) ->
    json = ccs.load file
    json.node
  setUIFile_JSON: (file) ->
    ccs.uiReader.widgetFromJsonFile file

  setBgColor: (color) ->
    @mBgFrame.setColor color

  onEnter : ->
    @_super()

  onExit: ->
    @_super()
