###
  棋盘
###

@ChessboardView = LayerBase.extend
  mCells              :         null      # 存放所有的单元颜色块的二维数组
  mDownCell           :         null      # 按下的单元颜色块
  mToCell             :         null      # 移动方向的单元颜色块
  mCanSwapCells       :         true      # 标记是否能够交换两个颜色块
  mSwapCells          :         []         # 记录最近交换的5组单元块的下标,避免快速多次点击造成位置不对的情况
  mCurStepSum         :         0          # 当前步数
  mGoalColorIndex     :         0          # 目标颜色下标
  mInitGoalColorSum   :         35         # 初始状态要求目标颜色块数目
  mCurGoalColorSum    :         0          # 当前目标颜色块的总数
  mGoalColorCells     :         []          # 目标颜色所在位置下标集合
  mScore              :         0           # 当前得分

  mChessColorRecord   :         []       # 记录5步以内的棋盘颜色
  mScoresRecord       :         []        # 记录5步的得分
  mGoalColorSumRecord :         []        # 记录5步的目标颜色数量

  mHadSelectMagic     :         false       # 标记是否已经选择魔术棒

  mOnColorChange           :         null        # 目标颜色块改变回调
  mOnStepChange           :         null        # 步数改变回调
  mOnScoreChange           :         null        # 得分改变回调



  ctor : ->
    @_super()
#    @_super(cc.color(200,100,50,200) )
    @initSize()
    @addCells()
    cc.eventManager.addListener(@onListener(), @)

  # 设置目标颜色数量
  setGoalColorSum : (sum) ->
    @mInitGoalColorSum = sum

# 初始化棋盘大小以及位置
  initSize : ->
    #设置当前层里面所有节点的描点也和该层相同
    @ignoreAnchorPointForPosition false
    @setAnchorPoint(cc.p(0.5, 0.5))
    @setContentSize(cc.winSize.width, cc.winSize.width)
#    @setPosition(cc.p(cc.winSize.width/2, cc.winSize.height/2))

  # 向棋盘添加颜色块
  addCells : ->
    Configs.setCellSum(9, 9)
    @mCells = []
    for i in [0...Configs.mCellSumX]
      @mCells[i] = []
      for j in [0...Configs.mCellSumY]
        colorIndex = GameUtil.getRandomInt(Configs.mColorSum-1) # 留一种颜色来替换掉多余的目标颜色
        node = ChessCell.create(colorIndex, i, j)
        @mCells[i][j] = node
        @addChild(node, 0)

  # 重置棋盘中所以单元块颜色
  resetChess : ->
#    @mCurStepSum = 0
    @mScore = 0
    @mCurGoalColorSum = 0

    @mChessColorRecord = null
    @mScoresRecord.length = null
    @mGoalColorSumRecord = null
    @mSwapCells = null
    @mSwapCells = []
    @mChessColorRecord = []
    @mScoresRecord.length = []
    @mGoalColorSumRecord = []

    for i in [0...Configs.mCellSumX]
      for j in [0...Configs.mCellSumY]
        colorIndex = GameUtil.getRandomInt(Configs.mColorSum-1) # 留一种颜色来替换掉多余的目标颜色
        @mCells[i][j].resetColor(colorIndex)
        @mCells[i][j].unselect()

    @scanAllCells()
    @adjustTargetColor()
    @scanOneColor(@mGoalColorIndex, false)
    @adjustTargetColor()

  # 处理点击item事件
  onListener : ->
    self = @
    return cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: true,
      onTouchBegan : (touch, event) ->
        target = event.getCurrentTarget()
        location = touch.getLocation()
        locationInNode = target.convertToNodeSpace(location) # 相对添加了目标节点的坐标
        s = target.getContentSize()
        rect = cc.rect(0, 0, s.width, s.height)
        if (cc.rectContainsPoint(rect, locationInNode))
          @lastX = location.x
          @lastY = location.y
          ret = GameUtil.getIndexByLocation(location.x, location.y)
          if self.mDownCell?
            self.mDownCell.unselect()
          if ret.isInCell
            # 使用魔术棒
            if self.mHadSelectMagic
              self.mDownCell = self.mCells[ret.i][ret.j]
              if (self.mDownCell.mColorIndex isnt self.mGoalColorIndex)
                self.mHadSelectMagic = false
                self.useMagic(self.mDownCell)
                return false
              self.mHadSelectMagic = false

            if self.mDownCell?
#              self.mDownCell.unselect()
              # 点击了相邻的单元块
              if GameUtil.isAdjacentSide(self.mDownCell.mX, self.mDownCell.mY, ret.i, ret.j) isnt GameUtil.DIRECTION.none
                self.mToCell = self.mCells[ret.i][ret.j]
                downPoint = self.mDownCell.getPoint()
                toPoint = self.mToCell.getPoint()
                self.swapCells(self, downPoint, toPoint)
                return false
            self.mDownCell = self.mCells[ret.i][ret.j]
            self.mDownCell.select()
            self.mCanSwapCells = true # 设置为可交换状态
            return true
          return false
        return false

      onTouchMoved : (touch, event) ->
        target = event.getCurrentTarget()
        moveX = touch.getLocationX()
        moveY = touch.getLocationY()
        if self.mDownCell? and ((Math.abs(moveX - @lastX) > 5) or (Math.abs(moveY - @lastY) > 5))
          locationInNode = target.convertToNodeSpace(touch.getLocation()) # 相对添加了目标节点的坐标
          downCellPosition = self.mDownCell.getPosition()
          downCellSize = self.mDownCell.getBoundingBox()
          downCellRect = cc.rect(downCellPosition.x, downCellPosition.y, \
            downCellSize.width + Configs.mCellGap, downCellSize.height + Configs.mCellGap)
          if (not cc.rectContainsPoint(downCellRect, locationInNode)) # 判断是否移动出了按下的单元块
            if (not self.mToCell) and self.mCanSwapCells
              ret = GameUtil.getIndexByLocation(moveX, moveY)
              downPoint = cc.p(self.mDownCell.mX, self.mDownCell.mY)
              toPoint = cc.p(ret.i, ret.j)
              direction = GameUtil.relativePoint(downPoint, toPoint)
              toPoint = GameUtil.getSideCellByDirection(downPoint, direction)
              if not toPoint?
                return
              if toPoint.x >= 0 and toPoint.x < Configs.mCellSumX and toPoint.y >= 0 and toPoint.y < Configs.mCellSumY
                self.mToCell = self.mCells[toPoint.x][toPoint.y]
                self.swapCells(self, downPoint, toPoint)
              @lastX = moveX
              @lastY = moveY


      onTouchEnded : (touch, event) ->
        target = event.getCurrentTarget()
        location = touch.getLocation()
        ret = GameUtil.getIndexByLocation(location.x, location.y)

  ###
    初始化扫描所以颜色块
  ###
  scanAllCells : ->
    for k in [0...Configs.mColorSum]
      if k is @mGoalColorIndex
        continue
      @scanOneColor(k, false)

    @scanOneColor(@mGoalColorIndex, false)

  ###
    重置扫描状态
  ###
  resetScanState :  ->
    for i in [0...Configs.mCellSumX]
      for j in [0...Configs.mCellSumY]
        @mCells[i][j].mScanState = false

  ###
    扫描一种颜色变色情况
  ###
  scanOneColor : (colorIndex, isScore) ->
    colorIndex = parseInt(colorIndex)
    @resetScanState() # 重置扫描状态
    for i in [0...Configs.mCellSumX]
      for j in [0...Configs.mCellSumY]
        if @mCells[i][j].mScanState || parseInt(@mCells[i][j].mColorIndex) is colorIndex
          @mCells[i][j].mScanState = true
          continue
        surroundCells = GameUtil.getSurroundCells(@mCells, i, j, colorIndex)
        if GameUtil.shouldChangeColor(surroundCells)
          @changeCellsColors(surroundCells, colorIndex, isScore)

  ###
    调整目标颜色数目
  ###
  adjustTargetColor : ->
    @mGoalColorCells = GameUtil.getGoalColorCells(@mCells, @mGoalColorIndex)
    if @mGoalColorCells.length < @mInitGoalColorSum
      # 添加目标颜色块
      @addTargetColorBlock()
    else if @mGoalColorCells.length > @mInitGoalColorSum
      # 删除目标颜色块
      @removeTargetColorBlock()
    @mCurGoalColorSum = @mGoalColorCells.length

  ###
    添加一块目标颜色块
  ###
  addTargetColorBlock : ->
    loseCount = 0
    while @mGoalColorCells.length < @mInitGoalColorSum
      i = GameUtil.getRandomInt(Configs.mCellSumX)
      j = GameUtil.getRandomInt(Configs.mCellSumY)
      if @mCells[i][j].mColorIndex isnt @mGoalColorIndex \
      and not GameUtil.hasSideColor(@mCells, i, j, @mGoalColorIndex)
        @mCells[i][j].resetColor(@mGoalColorIndex)
        @mGoalColorCells.push({'i':i, 'j':j})
      else
        loseCount++
        if loseCount > (Configs.mCellSumX * Configs.mCellSumY * 2)
          @resetChess()

  ###
    删除一块目标颜色块
  ###
  removeTargetColorBlock : ->
    loseCount = 0
    while @mGoalColorCells.length > @mInitGoalColorSum
      randomInt = GameUtil.getRandomInt(@mGoalColorCells.length)
      s = @mGoalColorCells[randomInt]
      if GameUtil.hasNotSideColor(@mCells, s.i, s.j, @mGoalColorIndex)
        @mCells[s.i][s.j].resetColor(Configs.mColorSum-1)
        @mGoalColorCells.splice(randomInt, 1)
      else
        loseCount++
        if loseCount > (Configs.mCellSumX * Configs.mCellSumY * 2)
          @resetChess()


  ###
    改变颜色,isScore是否计分
  ###
  changeCellsColors : (surroundCells, colorIndex, isScore) ->
    n = surroundCells.length
    colorIndex = parseInt(colorIndex)
    if isScore and colorIndex is @mGoalColorIndex
      AudioManager.playTurnAudio()
      @mScore += GameUtil.scoringFormula(n)
      @mOnScoreChange(@mScore)
      @mCurGoalColorSum += surroundCells.length
      @mOnColorChange(@mCurGoalColorSum)
#      jlog.i "mScore = " + @mScore + " @mCurGoalColorSum = " + @mCurGoalColorSum

    for site in surroundCells
      i = site.i
      j = site.j
      @mCells[i][j].resetColor(colorIndex, isScore)

  # 交换两个颜色块 isBack表示是否是回退，回退不在存到栈中
  swapCells : (self, downPoint, toPoint, isBack)->
    extracted = ->
      GameUtil.swapTwoCells(self.mDownCell, self.mToCell, cbFunc)
      self.mCells[toPoint.x][toPoint.y] = self.mDownCell
      self.mDownCell.setLocalZOrder(0)
      self.mCells[toPoint.x][toPoint.y].setXY(toPoint.x, toPoint.y)
      self.mCells[downPoint.x][downPoint.y] = self.mToCell
      self.mCells[downPoint.x][downPoint.y].setXY(downPoint.x, downPoint.y)
    if self.mDownCell?
      AudioManager.playTranspkAudio()

      self.mDownCell.unselect()
      cbFunc = ->
        length = if self.mSwapCells.length > 10 then 10 else self.mSwapCells.length
        if length <= 0
          return
        for i in [1..length]
          p = self.mSwapCells[self.mSwapCells.length-i]
          if p is false # p =false 表示是使用了魔法棒
            continue
          self.mCells[p.x][p.y].resetPosition()
      if not (isBack? and isBack)
        extracted()
        if self.mDownCell.mColorIndex isnt self.mToCell.mColorIndex
          self.mCurStepSum--
          self.recordLastStep(downPoint, toPoint)
        self.scanOneColor(self.mDownCell.mColorIndex, true)
        self.scanOneColor(self.mToCell.mColorIndex, true)

      else
        extracted()
        self.restoreLastStep()
        if self.mDownCell.mColorIndex isnt self.mToCell.mColorIndex
          self.mCurStepSum++
      jlog.i " self.mCurStepSum = " + self.mCurStepSum
      self.mOnStepChange(self.mCurStepSum)

      self.mToCell = null
      self.mDownCell = null

  # 记录上一步
  recordLastStep : (downPoint, toPoint) ->
    lastCellsColor = null
    lastCellsColor = []
    for i in [0...Configs.mCellSumX]
      lastCellsColor[i] = []
      for j in [0...Configs.mCellSumY]
        lastCellsColor[i][j] = @mCells[i][j].mColorIndex

    @mSwapCells.push(downPoint)
    @mSwapCells.push(toPoint)

    @mChessColorRecord.push(lastCellsColor)
    @mScoresRecord.push(@mScore)
    @mGoalColorSumRecord.push(@mCurGoalColorSum)
  # 还原上一步的颜色
  restoreLastStep : ->
    if @mChessColorRecord.length > 0
      lastCellsColor = @mChessColorRecord.pop()
      for i in [0...Configs.mCellSumX]
        for j in [0...Configs.mCellSumY]
          @mCells[i][j].resetColor(lastCellsColor[i][j])
    if @mScoresRecord.length > 0
      @mScore = @mScoresRecord.pop()
      @mOnScoreChange(@mScore)
    if @mGoalColorSumRecord.length > 0
      @mCurGoalColorSum = @mGoalColorSumRecord.pop()
      @mOnColorChange(@mCurGoalColorSum)

  setOnStepChange : (callback) ->
    @mOnStepChange = callback
  setOnScoreChange : (callback) ->
    @mOnScoreChange = callback
  setOnColorChange : (callback) ->
    @mOnColorChange = callback

  # 增加步数
  setStepSum : (stepSum) ->
    @mCurStepSum = stepSum
    jlog.i "@mCurStepSum = " + @mCurStepSum

# 回退一步
  backOneStep : ->
    toPoint = @mSwapCells.pop()
    downPoint = @mSwapCells.pop()
    if (toPoint is false ) or (downPoint is false) # 表示此步骤使用了魔法棒
      @restoreLastStep()
      return false
    @mDownCell = @mCells[downPoint.x][downPoint.y]
    @mToCell = @mCells[toPoint.x][toPoint.y]
    @swapCells(@, downPoint, toPoint, true)

    if ccUtil.isNative()
      umeng.MobClickCpp.use("props-1", 1, 2)

  # 使用魔术棒
  useMagic : (downCell) ->
    @recordLastStep(false, false)
    downCell.resetColor(@mGoalColorIndex)
    @mScore += GameUtil.scoringFormula(1)
    @mOnScoreChange(@mScore)
    @mCurGoalColorSum++
    @mOnColorChange(@mCurGoalColorSum)
    @scanOneColor(@mGoalColorIndex, true)

    if ccUtil.isNative()
      umeng.MobClickCpp.use("props-0", 1, 2)

  # 选择魔术棒
  selectMagic : ->
    @mHadSelectMagic = true


