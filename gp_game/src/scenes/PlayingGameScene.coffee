###
  玩游戏场景
###
PlayingGameLayer = LayerBase.extend
  mBgLayerColor       :       null        # 背景精灵
#  mPropsView          :       null        # 道具水平滚动栏
  mChessboard         :       null        # 棋盘
  mStepLabel          :       null        # 步数显示记录
  mGoalColorIndex     :       0            # 目标颜色下标
#  mGoalColorSprite    :       null        # 显示目标颜色精灵
  mScore              :       0            # 当前得分
  mScoreLabel         :       null         # 当前得分显示label
  mTimeLabel          :       null         # 计时label
  mInterval           :       null          # setInterval
  mGoalScoreLabel     :       null         # 目标分数
  mLevelLabel         :       null         # 关卡label
  mCurLevel           :       1             # 当前关卡

  mBtnOption          :       null         # 开始暂停按钮

  mLabelRightX        :       cc.winSize.width  # 记录右上角几个label的空白地方的左右边X坐标
  mLevelTitleLabel    :       null         # 关卡数
  mStepTitleLabel    :       null         # 剩余步数
  mTimeTitleLabel    :       null         # 剩余时间
  mScoreTitleLabel    :       null         # 目标分数
  mGoalScoreLabel         :       null

  mBtnOption          :         null      # 暂停开始按钮
  mMaskLayer            :        null     # 暂停情况下遮罩层
  mOverDialog         :         null      # 本关游戏结束弹窗
  mPauseDialog        :         null      # 点击暂停按钮弹窗

  mHadWin             :         false       # 记录是否已经完成通过本关
  mHadFails           :         false       # 本关失败

  mBtnMagicWand       :         null
  mBtnBackStep        :         null
  mBtnAddStep         :         null

#  mLevels: [{'goal_sum':35,'step_sum':25},{'goal_sum':35,'step_sum':20},{'goal_sum':35,'step_sum':15},{'goal_sum':30,'step_sum':25},{'goal_sum':30,'step_sum':20},{'goal_sum':30,'step_sum':15},{'goal_sum':25,'step_sum':30},{'goal_sum':25,'step_sum':25},{'goal_sum':25,'step_sum':20},{'goal_sum':20,'step_sum':30},{'goal_sum':20,'step_sum':25},{'goal_sum':20,'step_sum':20},{'goal_sum':15,'step_sum':40},{'goal_sum':15,'step_sum':35},{'goal_sum':15,'step_sum':30}]


  ctor : (level) ->
    @_super()
    @mCurLevel = level
    @addBgLayerColor()
    @addChessboardView()

    @addOperateBtn()
    @addBtnMagicWand()
    @addBtnBackStep()
    @addBtnAddStep()
    @addLevelLabel()
    @addScoreLabel()
    @onGameStart(@mCurLevel)


 # 添加目标颜色为背景颜色
  addBgLayerColor : ->
    @mBgLayerColor = new cc.LayerColor(Configs.mColors[0]) # TODO 暂定 0 位目标颜色
    @addChild(@mBgLayerColor)

  # 添加棋盘
  addChessboardView : ->
    @mChessboard = new ChessboardView()
    @mChessboard.attr
      anchorX : 0.5
      anchorY : 0
      x : cc.winSize.width / 2
      y : 200
    @addChild(@mChessboard, 0)

    @mChessboard.setOnColorChange(@onColorChange())
    @mChessboard.setOnStepChange(@onStepChange())
    @mChessboard.setOnScoreChange(@onScoreChange())

  # 添加暂停开始按钮
  addOperateBtn : ->
    pauseImg = new cc.MenuItemImage(resImg.pause)
    restartImg = new cc.MenuItemImage(resImg.restart)
    self = @
    menuItem =  new cc.MenuItemToggle(pauseImg, restartImg, (sender)->
      AudioManager.playClickAudio()
      # TODO 暂停开始逻辑
#      jlog.i "menuItem 回调"
      jlog.cc sender.getSelectedIndex()
      if sender.getSelectedIndex() is 0
#        jlog.i "开始"
        self.onStart()
      else if sender.getSelectedIndex() is 1
#        jlog.i "暂停"
        self.onPause(menuItem)

    , @)
    @mBtnOption = new cc.Menu(menuItem)
    @mBtnOption.attr
      anchorX : 0
      anchorY : 1
      x : 65 + pauseImg.width / 2
      y : cc.winSize.height - pauseImg.height / 2 - 50
    @addChild(@mBtnOption)

  # 开始按钮
  onStart : ->
    if @mMaskLayer?
      @mMaskLayer.removeFromParent(true)
      @mMaskLayer = null
      @mBtnOption.setLocalZOrder(0)
    if @mPauseDialog?
      @mPauseDialog.hidden()

  # 暂停按钮
  onPause : (menuItem) ->
    @mBtnOption.setLocalZOrder(15)
    @mMaskLayer = new MarkLayer(cc.color(0, 0, 0, 150))
    @mMaskLayer.attr
      anchorX : 0
      anchorY : 0
      width : cc.winSize.width
      height : 200 + @mChessboard.height
      x : 0
      y : 0
    @addChild(@mMaskLayer, 10)
    @mPauseDialog = new PauseDialog()
    self = @
    @mPauseDialog.setReplayCb(->
      jlog.i "重玩游戏回调"
      self.onGameStart(self.mCurLevel)
      self.mMaskLayer.removeFromParent(true)
      self.mMaskLayer = null
      self.mBtnOption.setLocalZOrder(0)
      menuItem.setSelectedIndex(0)
    )
    @addChild(@mPauseDialog, 10)

  # 添加魔术棒按钮
  addBtnMagicWand : ->
    @mBtnMagicWand = new ccui.Button()
    @mBtnMagicWand.loadTextureNormal(resImg.magic_wand, ccui.Widget.LOCAL_TEXTURE)
    @mBtnMagicWand.setPressedActionEnabled true
    @mBtnMagicWand.attr
      anchorY : 0
      x: cc.winSize.width / 4
      y: 70
    @mBtnMagicWand.setTouchEnabled true
    @addChild(@mBtnMagicWand, 5)
    self = @
    @mChessboard.setReleaseMagicCb(-> self.mBtnMagicWand.scale = 1.0)
    @mBtnMagicWand.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        jlog.i "魔术棒点击回调"
#        self.mhadSelectMagic = true
        self.mChessboard.selectMagic()
        self.mBtnMagicWand.scale = 1.5
    , @mBtnMagicWand

  # 添加退1步按钮
  addBtnBackStep : ->
    @mBtnBackStep = new ccui.Button()
    @mBtnBackStep.loadTextureNormal(resImg.back_step, ccui.Widget.LOCAL_TEXTURE)
    @mBtnBackStep.setPressedActionEnabled true
    @mBtnBackStep.attr
      anchorY : 0
      x: cc.winSize.width / 4 * 2
      y: 70
    @mBtnBackStep.setTouchEnabled(true)
    self = @
    @addChild(@mBtnBackStep, 5)
    @mBtnBackStep.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        jlog.i "返回1步点击回调"
        self.onBackOneStep()
    , @mBtnBackStep

  # 添加增加5步按钮
  addBtnAddStep : ->
    @mBtnAddStep = new ccui.Button()
    @mBtnAddStep.loadTextureNormal(resImg.add_5_step, ccui.Widget.LOCAL_TEXTURE)
    @mBtnAddStep.setPressedActionEnabled true
    @mBtnAddStep.attr
      anchorY : 0
      x: cc.winSize.width / 4 * 3
      y: 70
    @mBtnAddStep.setTouchEnabled(true)
    self = @
    @addChild(@mBtnAddStep, 5)
    @mBtnAddStep.addTouchEventListener (touch, event)->
      if event is ccui.Widget.TOUCH_ENDED
        AudioManager.playClickAudio()
        jlog.i "增加5步点击回调"
        self.setStepSum(5)
        if ccUtil.isNative()
          umeng.MobClickCpp.use("props-2", 1, 3)
    , @mBtnAddStep


  # 添加显示当前关卡的label
  addLevelLabel : ->
    @mLevelTitleLabel = new cc.LabelTTF("关卡数")
    @mLevelTitleLabel.fontSize = 25
    @mLevelTitleLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mLevelTitleLabel.attr
      anchorX : 1
      anchorY : 1
      x : cc.winSize.width - 65
      y : cc.winSize.height - 50
    @addChild(@mLevelTitleLabel, 0)
    @mLabelRightX = @mLevelTitleLabel.x - @mLevelTitleLabel.width

    @mLevelLabel = new cc.LabelTTF(@mCurLevel)
    @mLevelLabel.fontSize = 25
    @mLevelLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mLevelLabel.attr
      x : @mLevelTitleLabel.x - @mLevelTitleLabel.width / 2
      y : @mLevelTitleLabel.y - @mLevelTitleLabel.height - 20
    @addChild(@mLevelLabel, 0)

  # 添加步数记录显示
  addStepLabel : ->
    @mStepTitleLabel = new cc.LabelTTF("剩余步数")
    @mStepTitleLabel.fontSize = 25
    @mStepTitleLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mStepTitleLabel.attr
      anchorX : 1
      anchorY : 1
      x : @mLabelRightX - 20
      y : cc.winSize.height - 50
    @addChild(@mStepTitleLabel, 0)
    @mLabelRightX = @mStepTitleLabel.x - @mStepTitleLabel.width
    @mStepLabel = new cc.LabelTTF("0")
    @mStepLabel.fontSize = 25
    @mStepLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mStepLabel.attr
      x : @mStepTitleLabel.x - @mStepTitleLabel.width / 2
      y : @mStepTitleLabel.y - @mStepTitleLabel.height - 20
    @addChild(@mStepLabel, 0)

  # 步数限制label可见
  setStepLabelVisible : (isVisible) ->
    if isVisible and not @mStepTitleLabel?
      @addStepLabel()
    else if not isVisible and @mStepTitleLabel?
      @mStepTitleLabel.removeFromParent(false)
      @mStepLabel.removeFromParent(false)

  # 添加计时label
  addTimeLabel : ->
    @mTimeTitleLabel = new cc.LabelTTF("剩余时间")
    @mTimeTitleLabel.fontSize = 25
    @mTimeTitleLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mTimeTitleLabel.attr
      anchorX : 1
      anchorY : 1
      x : @mLabelRightX - 20
      y : cc.winSize.height - 50
    @addChild(@mTimeTitleLabel, 0)
    @mLabelRightX = @mTimeTitleLabel.x - @mTimeTitleLabel.width
    @mTimeLabel = new cc.LabelTTF(StringUtil.toString(0))
    @mTimeLabel.fontSize = 25
    @mTimeLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mTimeLabel.attr
      x : @mTimeTitleLabel.x - @mTimeTitleLabel.width / 2
      y : @mTimeTitleLabel.y - @mTimeTitleLabel.height - 20
    @addChild(@mTimeLabel, 0)

  # 时间限制label可见
  setTimeLabelVisible : (isVisible) ->
    if isVisible and not @mTimeTitleLabel?
      @addTimeLabel()
    else if not isVisible and @mTimeTitleLabel?
      @mTimeTitleLabel.removeFromParent(false)
      @mTimeLabel.removeFromParent(false)

  # 添加目标分数Label
  addGoalScoreLabel : ->
    @mScoreTitleLabel = new cc.LabelTTF("目标分数")
    @mScoreTitleLabel.fontSize = 25
    @mScoreTitleLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mScoreTitleLabel.attr
      anchorX : 1
      anchorY : 1
      x : @mLabelRightX - 20
      y : cc.winSize.height - 50
    @addChild(@mScoreTitleLabel, 0)
    @mLabelRightX = @mScoreTitleLabel.x - @mScoreTitleLabel.width
    @mGoalScoreLabel = new cc.LabelTTF(StringUtil.toString(0))
    @mGoalScoreLabel.fontSize = 25
    @mGoalScoreLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mGoalScoreLabel.attr
      x : @mScoreTitleLabel.x - @mScoreTitleLabel.width / 2
      y : @mScoreTitleLabel.y - @mScoreTitleLabel.height - 20
    @addChild(@mGoalScoreLabel, 0)

  # 分数限制label可见
  setScoreLabelVisible : (isVisible) ->
    if isVisible and not @mScoreTitleLabel?
      @addGoalScoreLabel()
    else if not isVisible and @mScoreTitleLabel?
      @mScoreTitleLabel.removeFromParent(false)
      @mGoalScoreLabel.removeFromParent(false)

  # 添加显示得分的Label
  addScoreLabel : ->
    @mScoreLabel = new cc.LabelTTF("17305")
    @mScoreLabel.fontSize = 100
    @mScoreLabel.fillStyle = cc.color(255, 255, 255, 255)
    @mScoreLabel.attr
      anchorX : 0
      anchorY : 1
      x : 65
      y : cc.winSize.height - 180
    @addChild(@mScoreLabel, 0)


  # 目标颜色
  setGoalColor : ->
    @mGoalColorIndex = 0 # GameUtil.getRandomInt(Configs.mColorSum-1)
#    @mGoalColorSprite.setColor(Configs.mColors[@mGoalColorIndex])
    @mChessboard.mGoalColorIndex = @mGoalColorIndex
    @mBgLayerColor.setColor(Configs.mColors[@mGoalColorIndex])

  # 重置游戏
  onGameStart : (level) ->

    if ccUtil.isNative()
      umeng.MobClickCpp.startLevel("level-" + level)
    self = @
    @initGameParam(level)
#    @mTimeLabel.setString('0')
    @setGoalColor()
    @mChessboard.resetChess()

  # 初始化游戏参数
  initGameParam : (level) ->
    @mHadFails = false
    @mHadWin = false
    @mScore = 0
    @mLevelLabel.setString(level)
    @mScoreLabel.setString('0')
#    level = 42
    # TODO
    level = level % 50
    @mCurLevel = level
    Configs.setColors(level)

    goalColorSum = GameUtil.getGoalColorSum(level)
    @mChessboard.setGoalColorSum(goalColorSum)

    limitStep = GameUtil.getLimitStep(level)
    if limitStep is false
      @setStepLabelVisible(false)
    else
      @setStepLabelVisible(true)
      @mStepLabel.setString(limitStep.toString())
      @mChessboard.setStepSum(limitStep)

    limitTime = GameUtil.getLimitTime(level)
    if limitTime is false
      @setTimeLabelVisible(false)
    else
      @setTimeLabelVisible(true)
      @mTimeLabel.setString(limitTime.toString())
      self = @
      @mInterval = TimeUtil.startTimer(self.mInterval, ->
        t = parseInt(self.mTimeLabel.string)
        t--
        self.mTimeLabel.string = t.toString()
        if t <= 0
          self.onGameFails()
          clearInterval(self.mInterval)
      )

    limitScore = GameUtil.getLimitScore(level)
    if limitScore is false
      @setScoreLabelVisible(false)
    else
      @setScoreLabelVisible(true)
      @mGoalScoreLabel.setString(limitScore.toString())

  # 目标颜色改变回调
  onColorChange : ->
    self = @
    return (curGoalColorSum) ->
      if curGoalColorSum >= (Configs.mCellSumX * Configs.mCellSumY)
        if GameUtil.getLimitScore(self.mCurLevel) is false
          self.onGameWin()
        else
#          self.setScore(self, score)
          if GameUtil.getLimitScore(self.mCurLevel) > self.mScore
            self.onGameFails()
          else
            self.onGameWin()
  # 步数改变回调
  onStepChange : ->
    self = @
    return (step) ->
      self.setStep(step)
  # 得分改变
  onScoreChange : ->
    self = @
    return (score) ->
      self.setScore(score)

  setStep : (step) ->
    if GameUtil.getLimitStep(@mCurLevel) is false
      return
    sum = GameUtil.getLimitStep(@mCurLevel)
#    _step = sum - step
    @mStepLabel.string = step
    if step <= 0
      @onGameFails()

  # 剩余步数减一
  reduceStep : ->
    if GameUtil.getLimitStep(@mCurLevel) is false
      return
    step = @mStepLabel.string
    step = parseInt(step)
    step--
    @mStepLabel.string = step
    if step <= 0
      @onGameFails()

  # 增加步数
  setStepSum : (stepSum) ->
    if GameUtil.getLimitStep(@mCurLevel) is false
      return
    step = @mStepLabel.string
    step = parseInt(step)
    step += stepSum
    @mStepLabel.string = step
    @mChessboard.setStepSum(step)

  # 回退一步
  onBackOneStep :  ->
    if @mChessboard.mSwapCells.length > 0
      @mChessboard.backOneStep()
    else
      jlog.i "不可回退"

  # 设置得分
  setScore : (score) ->
    @mScoreLabel.string = score
    @mScore = score

  # 游戏结束
  onGameFails :  ->
    self = @
    if @mHasWin or @mHadFails
      return
    @mHadFails = true
    AudioManager.playFailsAudio()

    if ccUtil.isNative()
      umeng.MobClickCpp.failLevel("level-" + @mCurLevel)

    BmobHelper.saveGameFail(Configs.mUserId, @mCurLevel,  @mScore) # 保存至服务器

    @onGameOver(@mCurLevel, 2, @mScore)

#    @mOverDialog = new GameOverDialog(resImg.lose, "再来一次")
#    @addChild(@mOverDialog, 10)
#    @mOverDialog.setBtnCallback(->
#      self.replayThisLevel()
#      self.mHadFails = false
#    )
#    @mOverDialog.setHiddenCallback( ->
#      self.back()
#      self.mHadFails = false
#    )

  # 完成本关游戏
  onGameWin : ->
    if @mHadFails or @mHasWin
      return
    @mHasWin = true
    AudioManager.playWinAudio()
    if ccUtil.isNative()
      umeng.MobClickCpp.finishLevel("level-" + @mCurLevel)
    DataUtil.saveLevelScore(@mCurLevel,  @mScore) # 保存到本地

    BmobHelper.saveGameWin(Configs.mUserId, @mCurLevel,  @mScore) # 保存至服务器
    jlog.i "@mScore = " + @mScore
    @onGameOver(@mCurLevel, 1, @mScore)

#    @mOverDialog = new GameOverDialog(resImg.win, "下一关")
#    @addChild(@mOverDialog, 10)
#    self = @
#    @mOverDialog.setBtnCallback(->
#      self.nextLevel()
#      self.mHasWin = false
#    )
#    @mOverDialog.setHiddenCallback( ->
#      self.back()
#      self.mHasWin = false
#    )
#      self.back()

  # 重玩本关
  replayThisLevel : ->
    @onGameStart(@mCurLevel)

  # 下一关
  nextLevel : ->
    @mCurLevel++
    @onGameStart(@mCurLevel)

  onGameOver : (level, type, score) ->
    playScene = new StartGameScene(level, type, score)
    cc.director.runScene(playScene)

  # 返回游戏主界面
  back : ->
    cc.director.runScene(new MainScene1())

@PlayingGameScene = cc.Scene.extend
  mLevel        :         1
  ctor : (level) ->
    @_super()
    @mLevel = level

  onEnter : ->
    this._super()
    layer = new PlayingGameLayer(@mLevel)
    this.addChild(layer)
    AudioManager.initBgm()
#    cc.audioEngine.playMusic(resAudio.bg_music, true)
  onExit : ->
    AudioManager.stopBgm()
#    cc.audioEngine.stopMusic()




