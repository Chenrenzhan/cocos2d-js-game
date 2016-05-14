###
  设置对话框
###

@SettingsDialog = PopLayerBase.extend
  mBgLayer        :     null  # 背景layer
  mBtnClose       :     null  # 关闭按钮
  mMusic          :     null  # 背景音乐
  mSound          :     null  # 音效

  mCloseCallback : null # 关闭按钮回调

  ctor : () ->
    @_super()
    @setTouchbgHide(false)
    @addBgLayer()
    @addCloseBtn()
    @addMusic()
    @addSound()

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
        self.hidden(self.mCloseCallback)
    , @mBtnClose

  # 添加背景音乐开关
  addMusic : ->
    label = new cc.LabelTTF("音乐")
    label.attr
      fillStyle : cc.color(0, 0, 0, 255)
      fontSize  : 40
      anchorX : 0
      anchorY : 0.5
      x : 50
      y : 180
    @mBgLayer.addChild(label)
    index = if Configs.mData[Keys.MUSIC] then 0 else 1
    @mMusic = @createToggle(index,
      ->
        jlog.i "打开音乐"
        AudioManager.playBgm()
#        DataUtil.saveMusicSettings(true)
      ->
        jlog.i "关闭音乐"
        AudioManager.stopBgm()
#        DataUtil.saveMusicSettings(false)
    )
    @mMusic.attr
      anchorX : 1
      anchorY : 0.5
      x : @mBgLayer.width - 100
      y : label.y
    @mBgLayer.addChild(@mMusic, 5)


  # 添加音效开关
  addSound : ->
    label = new cc.LabelTTF("音效")
    label.attr
      fillStyle : cc.color(0, 0, 0, 255)
      fontSize  : 40
      anchorX : 0
      anchorY : 0.5
      x : 50
      y : 90
    @mBgLayer.addChild(label)
    index = if Configs.mData[Keys.SOUND] then 0 else 1
    @mSound = @createToggle(index,
      ->
        AudioManager.saveIsSound(true)
      ->
        AudioManager.saveIsSound(false)
    )
    @mSound.attr
      anchorX : 1
      anchorY : 0.5
      x : @mBgLayer.width - 100
      y : label.y
    @mBgLayer.addChild(@mSound, 5)

  # 创建开关按钮
  createToggle : (selectIndex, noCallback, offCallback)->
    toggleNo = new cc.MenuItemImage(resImg.toggle_no)
    toggleOff = new cc.MenuItemImage(resImg.toggle_off)
    self = @
    menuItem =  new cc.MenuItemToggle(toggleNo, toggleOff, (sender)->
      AudioManager.playClickAudio()
      if sender.getSelectedIndex() is 0
        noCallback()
      else if sender.getSelectedIndex() is 1
        offCallback()
    , @)
    menuItem.setSelectedIndex(selectIndex)
    menu = new cc.Menu(menuItem)
    return menu


  setHiddenCallback : (fun) ->
    @mCloseCallback = fun



  