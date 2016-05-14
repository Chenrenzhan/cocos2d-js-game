###
  暂停对话框
###

@PauseDialog = PopLayerBase.extend
#  mBgLayer: null
  mBtnReplay      :     null # 重玩按钮
  mBtnBackward    :     null # 返回游戏主界面游戏

  mCloseCallback : null # 关闭按钮回调
  mReplayCb       :     null # 重玩回调

  ctor : ->
    @_super()
    @addBtnLayer()
    @addReplayBtn()
    @addExitGameBtn()
    @markLayer()
    @show()

  addBtnLayer : ->
    @mBgLayer = new cc.LayerColor(cc.color(255,255,255, 255), 400, 150)
    @mBgLayer.ignoreAnchorPointForPosition(false)
    @mBgLayer.attr
      anchorX : 0.5
      anchorY : 0.5
      x : cc.winSize.width / 2
      y : cc.winSize.height / 2
    @addChild @mBgLayer, 0

  # 重玩按钮
  addReplayBtn : ->
    @mBtnReplay = new ccui.Button()
    @mBtnReplay.loadTextureNormal resImg.replay, ccui.Widget.LOCAL_TEXTURE
    @mBtnReplay.setPressedActionEnabled true
    @mBtnReplay.attr
      anchorX : 1
      x: @mBgLayer.width / 3
      y: @mBgLayer.height / 2
    @mBtnReplay.setTouchEnabled true
    @mBgLayer.addChild @mBtnReplay, 50

    self = @
    @mBtnReplay.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        jlog.i "点击重玩按钮"
        self.mReplayCb()
        self.hidden()
    , @mBtnReplay

  # 退出游戏按钮
  addExitGameBtn : ->
    @mBtnBackward = new ccui.Button()
    @mBtnBackward.loadTextureNormal resImg.backward, ccui.Widget.LOCAL_TEXTURE
    @mBtnBackward.setPressedActionEnabled true
    @mBtnBackward.attr
      anchorX : 0
      x: @mBgLayer.width / 3 * 2
      y: @mBgLayer.height / 2
    @mBtnBackward.setTouchEnabled true
    @mBgLayer.addChild @mBtnBackward, 50

    self = @
    @mBtnBackward.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        cc.director.runScene(new MainScene())
    , @mBtnBackward

  setReplayCb : (fun) ->
    @mReplayCb = fun
