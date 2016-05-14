###
  自定义纯颜色按钮控件
###

@PureColorButton = cc.Node.extend
  mLayerColor       :       null                  # 颜色层
  mSize             :       cc.p(230, 75)         # 默认大小
  mNormalColor      :       cc.color(255,54,54)   # 常态下颜色
  mSelectColor      :       null                  # 选择下颜色
  mDisableColor     :       cc.color(79,79,79)    # 不可用下颜色
  mIsEnable         :       true                  # 是否可点击
  mTitleText        :       ""                    # 按钮文字
  mTitleLabel       :       null                  # 显示按钮文字Label
  mFontColor        :       cc.color(255,255,255) # 按钮文字颜色
  mFontSize         :       35                    # 按钮字体大小

  mCallback         :       null                   # 点击回调

  ctor : (param) ->
    @_super()
    @ignoreAnchorPointForPosition(false)
    @initParam(param)
    @setContentSize(@mSize.x, @mSize.y)
    @addColorLayer()
    @addBtnTitle()
    @onListener()

  # 参数
  initParam : (param) ->
    if ccUtil.isObjectNotNull(param)
#      switch
      if ccUtil.isObjectNotNull(param.normal) then @mNormalColor = param.normal
      if ccUtil.isObjectNotNull(param.select) then @mSelectColor = param.select
      if ccUtil.isObjectNotNull(param.disable) then @mDisableColor = param.disable
      if ccUtil.isObjectNotNull(param.title) then @mTitleText = param.title
      if ccUtil.isObjectNotNull(param.enable) then @mIsEnable = param.enable
      if ccUtil.isObjectNotNull(param.size) then @mSize = param.size
      if ccUtil.isObjectNotNull(param.callback) then @mCallback = param.callback
      if ccUtil.isObjectNotNull(param.fontColor) then @mFontColor = param.fontColor
      if ccUtil.isObjectNotNull(param.fontSize) then @mFontSize = param.fontSize
    if not @mSelectColor?
      @mSelectColor = @mNormalColor

  # 添加颜色背景层
  addColorLayer : ->
    @mLayerColor = new cc.LayerColor(@mNormalColor)
    @mLayerColor.ignoreAnchorPointForPosition(false)
    if not @mIsEnable
      @mLayerColor.setColor(@mDisableColor)
    @mLayerColor.attr
      anchorX : 0.5
      anchorY : 0.5
      width : @mSize.x
      height : @mSize.y
      x : @width / 2
      y : @height / 2
    @addChild(@mLayerColor, 0)

  # 添加按钮标题
  addBtnTitle : ->
#    @mTitleText = "下一关"
    @mTitleLabel = new cc.LabelTTF(@mTitleText)
    @mTitleLabel.attr
      anchorX : 0.5
      anchorY : 0.5
      x : @mLayerColor.width / 2
      y : @mLayerColor.height / 2
      fontSize : @mFontSize
      fillStyle : @mFontColor
    @mLayerColor.addChild(@mTitleLabel, 0)

  # 事件
  onListener : ->
    self = @
    listener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: true                   # 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
      onTouchBegan: (touch, event) ->
        if not self.mIsEnable
          return false
        target = event.getCurrentTarget()  #获取事件所绑定的 target
        # 获取当前点击点所在相对按钮的位置坐标
        locationInNode = target.convertToNodeSpace touch.getLocation()
        s = target.getContentSize()
        rect = cc.rect(0, 0, s.width, s.height)
        if  cc.rectContainsPoint(rect, locationInNode)      #点击范围判断检测
          self.mLayerColor.setColor(self.mSelectColor)
          return true
        else
          return false

      onTouchMoved: (touch, event) ->

      onTouchEnded: (touch, event) ->
        if self.mCallback?
          self.mCallback()
#        ccUtil.callFunc(self.mCallback)
        self.mLayerColor.setColor(self.mNormalColor)

    cc.eventManager.addListener(listener, @mLayerColor)

  setCallBack : (cb) ->
    @mCallback = cb

