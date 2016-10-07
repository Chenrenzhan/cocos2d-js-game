

@LevelLayer = cc.LayerColor.extend
  mBigLevel         :         0
  mIsMark           :         false
  mCurLevel         :         0


  ctor : (color, bigLevel, isMark)->
    @_super(color)
    @mCurLevel = DataUtil.getDataItem(Keys.CURRENT_LEVEL, 0)
    @mBigLevel = bigLevel
    @mIsMark = isMark
    @addLevelTheme()
    @addLevel()
    @markLayer(isMark)

  addLevelTheme : ->
    theme = new cc.LabelTTF(Configs.mStyle[@mBigLevel])
    theme.attr
      fontSize : 50
      anchorX : 0.5
      anchorY : 1
      x : cc.winSize.width / 2
      y : 220
    @addChild(theme, 0)

  addLevel : ->

    for i in [1..5]
      level = @mBigLevel * 5 + i
      label = new cc.LabelTTF(level.toString())
      label.attr
        fontSize : 60
        anchorX : 0.5
        anchorY : 0
        opacity : 125
        x : cc.winSize.width / 6 * i
        y : 40
      @addChild(label, 0)

      jlog.i "@mCurLevel = " + @mCurLevel
      if level <= (@mCurLevel + 1)
        label.opacity = 255
        self = @
        TouchUtil.onClick(label,(target) ->
          jlog.i "level = " + level + "    " + target.string
          l = parseInt(target.string)
          self.onStartGame(l)
        )

  # 添加遮罩层
  markLayer : (isMark)->
    @mIsMark = isMark
    isMark = false
    if isMark
      if not @mark?
        @mark = new cc.LayerColor(cc.color(69, 69, 69, 120))
        @mark.setContentSize(cc.winSize.width, 256)
        @addChild(@mark, 10)

#        TouchUtil.cannotClick(@mark)
      else
        @mark.setLocalZOrder(10)
    else if @mark?
      @mark.setLocalZOrder(-1)

  # 开始游戏
  onStartGame : (level) ->
    AudioManager.playStartGameAudio()
    playScene = new StartGameScene(level, 0)
    cc.director.runScene(playScene)
