
MainLayer = cc.LayerColor.extend
  mCurLevel         :         0         # 当前最近关卡
  mLevel            :         0         # 当前点击打开的关卡
  mType             :         0         # 类型，0--详情页，1--通关页，2--失败页
  mTypeColor        :         [cc.color(225, 82, 88), cc.color(225, 82, 88), cc.color(179, 212, 101)]
  mTypeImg          :         [resImg.win_cat, resImg.win_cat, resImg.lose_cat]
  mFontColor        :         cc.color(255, 226, 138)
  mScore            :         Configs.mData[Keys.LEVEL_HIGHEST_SCORE]

  ctor :(level, type, score) ->
    @_super(@mTypeColor[type])
    @mCurLevel = DataUtil.getDataItem(Keys.CURRENT_LEVEL, 0)
    @mLevel = level
    jlog.i "@mCurLevel = " + @mCurLevel  + " ;   @mLevel = " + @mLevel
    jlog.i " isWin  = " + type
    @mType = type
    @mScore = score
#    @ignoreAnchorPointForPosition(false)

    @addBack()
    @addLevel()
    @addScoreLabel()
    @addStates()
    @addBtn()
    @addShare()

  addBack : ->
    layer = new cc.LayerColor(cc.color(73, 124, 189))
    layer.ignoreAnchorPointForPosition(false)
    layer.attr
      anchorX : 0.5
      anchorY : 1
      width : cc.winSize.width
      height : 90
      x : cc.winSize.width / 2
      y : cc.winSize.height
    @addChild(layer, 0)

    sprite = new cc.Sprite(resImg.close_white)
    sprite.attr
      x : layer.width / 2
      y : layer.height / 2
    layer.addChild(sprite, 0)

    TouchUtil.onClick(layer, ->
      cc.director.runScene(new MainScene1())
    )

  addLevel : ->
    bigLevel = Math.floor((@mLevel - 1) / 5)
    bigLabel = new cc.LabelTTF(Configs.mStyle[bigLevel])
    bigLabel.attr
      fontSize : 50
      fillStyle : @mFontColor
      x : cc.winSize.width / 2
      y : cc.winSize.height - 150
    @addChild(bigLabel, 0)

    levelLabel = new cc.LabelTTF(@mLevel.toString())
    levelLabel.attr
      fontSize : 50
      fillStyle : @mFontColor
      x : cc.winSize.width / 2
      y : bigLabel.y - bigLabel.height - 20
    @addChild(levelLabel, 0)

  addScoreLabel : ->
#    scores = @mScore
#    jlog.i "mLeve = " + @mLevel
#    jlog.cc scores
#    if not scores?
#      scores = []
    score = @mScore
    if not score?
      score = 0
    label = new cc.LabelTTF(score.toString())
    label.attr
      fontSize : 160
      fillStyle : @mFontColor
      x : cc.winSize.width / 2
      y : cc.winSize.height - 350
    @addChild(label, 0)

  addStates : ->
    sprite = new cc.Sprite(@mTypeImg[@mType])
    sprite.attr
      x : cc.winSize.width / 2
      y : cc.winSize.height / 2 + 80
    @addChild(sprite, 0)


  addBtn : ->
    layer = new cc.LayerColor(cc.color(73, 124, 189))
    layer.ignoreAnchorPointForPosition(false)
    layer.attr
      width : cc.winSize.width
      height : 200
      x : cc.winSize.width / 2
      y : 440
    @addChild(layer, 0)
    jlog.i "@@mType  =  " + @mType
    if @mLevel <= @mCurLevel or (@mType is 1)
      start = new cc.Sprite(resImg.start)
      start.attr
        x : cc.winSize.width / 3
        y : layer.height / 2 + 20
      layer.addChild(start)
      startLabel = new cc.LabelTTF("开始")
      startLabel.attr
        fontSize : 30
        fillStyle : @mFontColor
        x : start.x
        y : layer.height / 2 - 40
      layer.addChild(startLabel)
      next = new cc.Sprite(resImg.next_level)
      next.attr
        x : cc.winSize.width / 3 * 2
        y : layer.height / 2 + 20
      layer.addChild(next)
      nextLabel = new cc.LabelTTF("下一关")
      nextLabel.attr
        fontSize : 30
        fillStyle : @mFontColor
        x : next.x
        y : layer.height / 2 - 40
      layer.addChild(nextLabel)
      self = @
      TouchUtil.onClick(next, (target)->
        self.onStartGame(self.mLevel + 1)
      )
      TouchUtil.onClick(nextLabel, (target)->
        self.onStartGame(self.mLevel + 1)
      )
    else
      start = new cc.Sprite(resImg.start)
      start.attr
        x : cc.winSize.width / 2
        y : layer.height / 2 + 20
      layer.addChild(start)
      startLabel = new cc.LabelTTF("开始")
      startLabel.attr
        fontSize : 30
        fillStyle : @mFontColor
        x : start.x
        y : layer.height / 2 - 40
      layer.addChild(startLabel)

    self = @
    TouchUtil.onClick(start, (target)->
      self.onStartGame(self.mLevel)
    )
    TouchUtil.onClick(startLabel, (target)->
      self.onStartGame(self.mLevel)
    )

  addShare : ->
    weixin = new cc.Sprite(resImg.weixin)
    weixin.attr
      x : cc.winSize.width / 3 * 2
      y : 200
    @addChild(weixin)
    weixinLabel = new cc.LabelTTF("朋友圈")
    weixinLabel.attr
      fontSize : 30
      fillStyle : @mFontColor
      x : weixin.x
      y : 100
    @addChild(weixinLabel)
    qq = new cc.Sprite(resImg.qq)
    qq.attr
      x : cc.winSize.width / 3
      y : 200
    @addChild(qq)
    qqLabel = new cc.LabelTTF("QQ")
    qqLabel.attr
      fontSize : 30
      fillStyle : @mFontColor
      x : qq.x
      y : 100
    @addChild(qqLabel)


  # 开始游戏
  onStartGame : (level) ->
    AudioManager.playStartGameAudio()
    playScene = new PlayingGameScene(level)
    cc.director.runScene(playScene)

@StartGameScene = cc.Scene.extend
  mLevel        :         0
  mType        :         0
  mScore        :         0
  ctor : (level, type, score) ->
    @_super()
    @mLevel = level
    @mType = type
    if score?
      @mScore = score
    else
      scores = Configs.mData[Keys.LEVEL_HIGHEST_SCORE]
      @mScore = if scores? then scores[level-1] else 0
  onEnter: ->
    this._super()
    layer = new MainLayer(@mLevel, @mType, @mScore)
    this.addChild(layer)
#    AudioManager.initBgm()