###
  游戏主界面
###

MainLayer = LayerBase.extend
  mScrollView             :       null            # 可滚动的视窗
  mBtnSettings            :       null            # 设置按钮
  mLastOpenLevel          :       1               # 最上面一个通过的关卡
  mMenuLayerHeight        :       140             # 菜单栏高度
  mMenuLayer              :       null            # 菜单栏
  mBtnExit                :       null            # 退出游戏按钮

  ctor : ->
    @_super()
    @mCurLevel = DataUtil.getDataItem(Keys.CURRENT_LEVEL, 0)
    @addMenuLayer()
    @addBtnFriend()
    @addBtnSettings()
    @addBtnExitGame()
    @initScrollView()
    @addVerticalLine(1)
    @addVerticalLine(2)
    @addVerticalLine(3)

    for i in [1..50]
      @addLevelCard(i)

  # 添加下面菜单栏
  addMenuLayer : ->
    @mMenuLayer = new cc.LayerColor(cc.color(168, 132, 174, 255))
    @mMenuLayer.ignoreAnchorPointForPosition(false)
    @mMenuLayer.attr
      width : cc.winSize.width
      height : @mMenuLayerHeight
      anchorX : 0.5
      anchorY : 0
      x : cc.winSize.width / 2
      y : 0
    @addChild(@mMenuLayer, 5)
    TouchUtil.onClick(@mMenuLayer, ->
      return false
    )

  # 添加设置按钮
  addBtnSettings : ->
    btn = new ccui.Button()
    btn.loadTextureNormal(resImg.settings, ccui.Widget.LOCAL_TEXTURE)
    btn.setPressedActionEnabled(true)
    btn.setTouchEnabled(true)
    btn.attr
      anchorX : 0
      anchorY : 0.5
      x: 50
      y: @mMenuLayer.height / 2
    @mMenuLayer.addChild(btn, 5)
    self = @
    btn.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        jlog.i "设置按钮点击回调"
        settingsDialog = new SettingsDialog()
        self.addChild(settingsDialog, 2000)
        jlog.i "settingsDialog   =  " + settingsDialog.getLocalZOrder()
    , btn

  # 添加好友按钮
  addBtnFriend : ->
    btn = new ccui.Button()
    btn.loadTextureNormal(resImg.friend, ccui.Widget.LOCAL_TEXTURE)
    btn.setPressedActionEnabled(true)
    btn.setTouchEnabled(true)
    btn.attr
      anchorX : 0.5
      anchorY : 0.5
      x: @mMenuLayer.width / 2
      y: @mMenuLayer.height / 2
    @mMenuLayer.addChild(btn, 5)
    btn.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        jlog.i("QQ登录")
        if(ccUtil.isAndroid())
          # 调用java
          jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "loginQQ", "()V")
          jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "queryUserInfo", "()V")
    , btn
  # 添加退出游戏按钮
  addBtnExitGame : ->
    btn = new ccui.Button()
    btn.loadTextureNormal(resImg.exit_game, ccui.Widget.LOCAL_TEXTURE)
    btn.setPressedActionEnabled(true)
    btn.setTouchEnabled(true)
    btn.attr
      anchorX : 1.0
      anchorY : 0.5
      x: @mMenuLayer.width - 50
      y: @mMenuLayer.height / 2
    @mMenuLayer.addChild(btn, 5)
    self = @
    btn.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        confirm = new ConfirmExitDialog()
        self.addChild(confirm, 20)
        # 点击退出，保存游戏数据
        DataUtil.saveData()
    , btn

  initScrollView : ->
    self = @
    @mScrollView = new ccui.ScrollView()
    @mScrollView.setDirection(ccui.ScrollView.DIR_VERTICAL)
    if ccUtil.isNative()
      # 设置滚动条只有native才有效果，web会报错
      @mScrollView.setScrollBarEnabled(false)
    @mScrollView.setInertiaScrollEnabled(true)
    @mScrollView.setTouchEnabled(true)
    @mScrollView.setContentSize(cc.size(cc.winSize.width, cc.winSize.height-@mMenuLayerHeight))
    @mScrollView.setInnerContainerSize(cc.size(cc.winSize.width, (cc.winSize.height-@mMenuLayerHeight) * 5))
    @mScrollView.attr
      anchorX : 0.5
      anchorY : 1
      x : cc.winSize.width / 2
      y : cc.winSize.height
    percent = 100 - @mCurLevel / 50 * 100
    @mScrollView.scrollToPercentVertical(percent, 2, false)
    @addChild(@mScrollView, 0)
    bigLevels = Configs.mSettings[Keys.LEVELS]
    size = @mScrollView.getContentSize()
    for i in [0...bigLevels.length]
      layer = new cc.LayerColor(bigLevels[i].colors[0])
      layer.ignoreAnchorPointForPosition(false)
      layer.setContentSize(size)
      layer.attr
        x : cc.winSize.width / 2
        y : (cc.winSize.height - @mMenuLayerHeight) * (i + 0.5)
      sprite = new cc.Sprite(resImg.logo)
      sprite.attr
        x : layer.width / 2
        y : layer.height / 2
      layer.addChild(sprite, 0)
      @mScrollView.addChild(layer,0)

  # 添加界面中的三条竖线
  addVerticalLine : (index) ->
    line = new cc.LayerColor(cc.color(255,255,255,120))
    line.ignoreAnchorPointForPosition(false)
    line.attr
      width : 20
      height : @mScrollView.innerHeight
      anchorX : 0.5
      anchorY : 0
      x : @mScrollView.width / 4 * index
      y : 0
    @mScrollView.addChild(line,0)

  # 添加关卡卡片
  addLevelCard : (level) ->
    levelCard = new LevelCard(@getColor(level), level)
    scores = Configs.mData[Keys.LEVEL_HIGHEST_SCORE]
    if level <= @mCurLevel
      levelCard.openLevel(true)
      levelCard.setScore(scores[level-1])
      levelCard.setOnClickCallback(@onStartGame)
    else if @mCurLevel is (level-1)
      levelCard.nextOpenLevel()
      levelCard.setOnClickCallback(@onStartGame)
    else
      levelCard.openLevel(false)
#    levelCard.openLevel()
    line = level % 4
    switch(line)
      when 0 then line = 2
      when 2 then line = 2
      when 1 then line = 3
      when 3 then line = 1
    x = cc.winSize.width / 4 * line
    y = levelCard.height * (level - 1) + levelCard.height / 2
    levelCard.attr
      x : x
      y : y
    @mScrollView.addChild(levelCard, 5)

  getColor : (level) ->
    level = level - 1
    bigLevel = Math.floor(level / 10)
    sLevel = level % 10
    index = sLevel % 5 + 1
    color = Configs.mSettings[Keys.LEVELS][bigLevel][Keys.COLORS][index]
    return color

  # 开始游戏
  onStartGame : (level) ->
    AudioManager.playStartGameAudio()
    playScene = new PlayingGameScene(level)
    cc.director.runScene(playScene)

@MainScene = cc.Scene.extend
  onEnter: ->
    this._super()
    layer = new MainLayer()
    this.addChild(layer)
    AudioManager.initBgm()