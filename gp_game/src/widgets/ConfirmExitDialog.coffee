###
  确认退出对话框
###

@ConfirmExitDialog = PopLayerBase.extend
  mBgLayer        :     null  # 背景layer
  mBtnClose       :     null  # 关闭按钮

  mCloseCallback : null # 关闭按钮回调

  ctor : () ->
    @_super()
    @setTouchbgHide(false)
    @addBgLayer()
    @addCloseBtn()
    @addTip()
    @addBtnConfirm()
    @addBtnBack()

  addBgLayer : ->
    @mBgLayer = new cc.LayerColor(cc.color(255,255,255,255))
    @mBgLayer.ignoreAnchorPointForPosition(false)
    @mBgLayer.setContentSize(400, 300)
    @mBgLayer.attr
      x : cc.winSize.width / 2
      y : cc.winSize.height / 2
    @addChild(@mBgLayer)
    TouchUtil.cannotClick(@mBgLayer)

  addCloseBtn : ->
    @mBtnClose = new ccui.Button()
    @mBtnClose.loadTextureNormal resImg.close, ccui.Widget.LOCAL_TEXTURE
    @mBtnClose.setPressedActionEnabled true
    @mBtnClose.attr
      x: @mBgLayer.width - 30
      y: @mBgLayer.height - 30
    @mBtnClose.setTouchEnabled true
    @mBgLayer.addChild(@mBtnClose, 5)

    self = @
    @mBtnClose.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
#        LogTool.c "点击关闭按钮"
        self.hidden(self.mCloseCallback)
    , @mBtnClose

  # 添加提示语
  addTip : ->
    label = new cc.LabelTTF("您确定要退出游戏？")
    label.attr
      fontSize : 30
      fillStyle : cc.color(0, 0, 0, 255)
      x : @mBgLayer.width / 2
      y : @mBgLayer.height / 2 + 50
    @mBgLayer.addChild(label)

  # 添加确定按钮
  addBtnConfirm : ->
    param =
      normal : cc.color(52, 155, 255, 120)
      title : "确定"
      size : cc.p(120, 60)
      fontSize : 35
#      fontColor : cc.color(0, 0, 0)
      callback : ->
#        if cc.sys.isNative
        cc.director.end()
    btn = new PureColorButton(param)
    btn.attr
      anchorX : 0
      anchorY : 0.5
      x : 50
      y : 60
    @mBgLayer.addChild(btn, 5)


  # 添加返回按钮
  addBtnBack : ->
    self = @
    param =
      normal : cc.color(52, 155, 255, 255)
      title : "返回"
      size : cc.p(120, 60)
      fontSize : 35
#      fontColor : cc.color(0, 0, 0)
      callback : ->
        self.hidden(self.mCloseCallback)
    btn = new PureColorButton(param)
    btn.attr
      anchorX : 1
      anchorY : 0.5
      x : @mBgLayer.width - 50
      y : 60
    @mBgLayer.addChild(btn, 5)

  setHiddenCallback : (fun) ->
    @mCloseCallback = fun


