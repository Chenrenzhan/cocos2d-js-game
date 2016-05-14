###
  游戏结束对话框
###

@GameOverDialog = PopLayerBase.extend

#  mPopDialog : null
#  mBtnClose: null

  mBtnLayer   :   null # 按钮坐在的layer
  mBtn        :   null
  mBtnClose       :     null  # 关闭按钮

  mCloseCallback : null # 关闭按钮回调
  mBtnCallBack    :   null   # 点击按钮回调

  ctor : (img, title) ->
    @_super()
    @setTouchbgHide(false)
    @addBgLayer()
    @addImg(img)
    @addBtnLayer()
    @addCloseBtn()
    @addBtn(title)
    @show()

  addBgLayer : ->
    @mBgLayer = new cc.Layer()
    @mBgLayer.ignoreAnchorPointForPosition(false)
    @mBgLayer.setContentSize(400, 300)
    @mBgLayer.attr
      x : cc.winSize.width / 2
      y : cc.winSize.height / 2
    @addChild(@mBgLayer)

  # 添加成功或者失败的图片
  addImg : (img) ->
    sprite = new cc.Sprite img
    sprite.attr
      anchorX : 0.5
      anchorY : 1
      x : @mBgLayer.width / 2
      y : @mBgLayer.height
    @mBgLayer.addChild sprite, 0

  addBtnLayer : ->
    @mBtnLayer = new cc.LayerColor(cc.color(255,255,255,255), 400, 140)
    @mBtnLayer.ignoreAnchorPointForPosition(false)
    @mBtnLayer.attr
      anchorX : 0.5
      anchorY : 0
      x : @mBgLayer.width / 2
      y : 0
    @mBgLayer.addChild(@mBtnLayer, 0)
    @mPopDialog = new PopLayerBase @mBgLayer, true, true
    @addChild @mPopDialog

  addCloseBtn : ->
    @mBtnClose = new ccui.Button()
    @mBtnClose.loadTextureNormal(resImg.close, ccui.Widget.LOCAL_TEXTURE)
    @mBtnClose.setPressedActionEnabled true
    @mBtnClose.attr
      anchorX : 1
      anchorY : 1
      x: @mBtnLayer.width  - 15
      y: @mBtnLayer.height  - 15
    @mBtnClose.setTouchEnabled true
    @mBtnLayer.addChild @mBtnClose, 5

    self = @
    @mBtnClose.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
#        LogTool.c "点击关闭按钮"
        self.hidden(self.mCloseCallback)
    , @mBtnClose

  addBtn : (title) ->
    param = {"title": title}
    @mBtn = new PureColorButton(param)
    self = @

    @mBtn.setCallBack( ->
      self.hidden(self.mBtnCallBack)
    )
    @mBtn.attr
      anchorX : 0.5
      anchorY : 0.5
      x : @mBtnLayer.width / 2
      y : @mBtnLayer.height / 2
    @mBtnLayer.addChild(@mBtn, 0)

  setHiddenCallback : (fun) ->
    @mCloseCallback = fun

  setBtnCallback : (cb) ->
    @mBtnCallBack = cb
