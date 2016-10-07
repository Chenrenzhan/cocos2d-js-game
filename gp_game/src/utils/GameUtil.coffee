###
  游戏规则工具类
###

@GameUtil =

  DIRECTION :             # 上下左右四个方向
    left      :     0     # 左
    up        :     1     # 上
    right     :     2     # 右
    down      :     3     # 下
    none      :     -1    # 不在上下左右四个方向

  getRandomInt : (max) ->
    return Math.floor(Math.random() * max)

  # 根据当前点的位置坐标获取当前点坐在的单元颜色块的坐标,坐标相对于屏幕，即屏幕的左下角
  getIndexByLocation : (x, y) ->
    ret =
      'isInCell'  :   false   # 该点是否在单元颜色块上
      'i'         :   -1
      'j'         :   -1
    startY = 200 # Y轴起始坐标
    endY = startY + cc.winSize.width   # Y轴结束坐标
    if y < (startY + Configs.mBorderY) or y > (endY - Configs.mBorderY)
      return ret
    if x < Configs.mBorderX or x > (cc.winSize.width - Configs.mBorderX)
      return ret

    i = (x - Configs.mBorderX) / (Configs.mCellWidth + Configs.mCellGap)
    i = Math.floor(i)
    gapBeginX = Configs.mBorderX + i * (Configs.mCellWidth + Configs.mCellGap) + Configs.mCellWidth

    j = (y - startY - Configs.mBorderY) / (Configs.mCellWidth + Configs.mCellGap)
    j = Math.floor(j)
    gapBeginY = startY + Configs.mBorderY + j * (Configs.mCellWidth + Configs.mCellGap) + Configs.mCellWidth
    ret = {'isInCell': false, 'i': i, 'j': j}
    if x > gapBeginX or i >= Configs.mCellSumX
      return ret
    if y > gapBeginY or j >= Configs.mCellSumY
      return ret
    ret = {'isInCell': true, 'i': i, 'j': j}
    return ret

  # cell2 在 cell1的上下左右位置
  isAdjacentSide : (i1, j1, i2, j2) ->
    if (i1 is i2)
      if (j1 - j2) is 1
        return @DIRECTION.left
      else if (j2 - j1) is 1
        return @DIRECTION.right
    else if (j1 is j2)
      if (i1 - i2) is 1
        return @DIRECTION.left
      else if (i2- i1) is 1
        return @DIRECTION.right
    return @DIRECTION.none

  # point1 在 point2 的上下左右相对位置
  relativePoint : (point1, point2) ->
    if point1.x < 0 or point1.y < 0 or point2.x < 0 or point2.y < 0
      return @DIRECTION.none          # 不在棋盘范围内
    rate = (point2.y - point1.y) / (point2.x - point1.x)
    if (rate > -1) and (rate < 1)
      if point2.x > point1.x
        return @DIRECTION.right     # point2 在 point1 右边
      else if point2.x < point1.x
        return @DIRECTION.left      # point2 在 point1 左边
    else if (rate < -1) or (rate > 1)
      if point2.y > point1.y
        return @DIRECTION.up        # point2 在 point1 右边
      else if point2.y < point1.y
        return @DIRECTION.down      # point2 在 point1 左边
    return @DIRECTION.none          # 正好在斜对角线上

  # 根据方向获取相邻的颜色单元块
  getSideCellByDirection : (point, direction) ->
    i = point.x
    j = point.y
    switch direction
      when GameUtil.DIRECTION.left    then i--
      when GameUtil.DIRECTION.up      then j++
      when GameUtil.DIRECTION.right   then i++
      when GameUtil.DIRECTION.down    then j--
      when GameUtil.DIRECTION.none    then return null
    return cc.p(i, j)


  # 交换两个单元颜色块
  swapTwoCells : (downCell, toCell, cbFunc)->
    downCell.setLocalZOrder(5)
    downCell.runAction(ActionManager.swapCellsAction(toCell.getPosition()))
    toCell.runAction(ActionManager.swapCellsAction(downCell.getPosition(), cbFunc))

  ###
    以(x, y)作为起点进行扫描被colorIndex颜色包围住的所有颜色块
  ###
  getSurroundCells : (cells, x, y, colorIndex) ->
#    jlog.i "getSurroundCells x = " + x + "   ;   y = " + y + "   ;  colorIndex = " + colorIndex
    x = parseInt(x)
    y = parseInt(y)
    colorIndex = parseInt(colorIndex)
    queue = [] # 队列
    surroundCells = [] # 已经扫过被包围的节点

    cells[x][y].mScanState = true
    queue.push({'i': x, 'j': y})
    # 广度优先算法搜索
    while queue.length > 0
      site = queue.shift()
      x = site.i
      y = site.j
      # 下
      if (y - 1 >= 0) and (parseInt(cells[x][y - 1].mColorIndex) isnt colorIndex) and (not cells[x][y - 1].mScanState)
        cells[x][y - 1].mScanState = true
        queue.push({'i': x, 'j': y - 1})
      # 左
      if (x - 1 >= 0) and (parseInt(cells[x - 1][y].mColorIndex) isnt colorIndex) and (not cells[x - 1][y].mScanState)
        cells[x - 1][y].mScanState = true
        queue.push({'i': x - 1, 'j': y})
      # 上
      if (y + 1 < Configs.mCellSumY) and (parseInt(cells[x][y + 1].mColorIndex) isnt colorIndex) and (not cells[x][y + 1].mScanState)
        cells[x][y + 1].mScanState = true
        queue.push({'i': x, 'j': y + 1})
      # 右
      if (x + 1 < Configs.mCellSumX) and (parseInt(cells[x + 1][y].mColorIndex) isnt colorIndex) and (not cells[x + 1][y].mScanState)
        cells[x + 1][y].mScanState = true
        queue.push({'i': x + 1, 'j': y})

      surroundCells.push(site)
    return surroundCells

  ###
    分情况判断是否变色
  ###
  shouldChangeColor : (surroundCells) ->
    # 判断在边界的数目
    minEdge = if Configs.mCellSumX > Configs.mCellSumY then Configs.mCellSumX else Configs.mCellSumY
    if surroundCells.length < minEdge / 2 + 1
      return true
    else
    # 可能变色， 判断边界数目
      left = 0
      right = 0
      up = 0
      down = 0
      for site in surroundCells
#        s = surroundCells[l]
        if site.i is 0
          left++
        if site.i is (Configs.mCellSumX-1)
          right++
        if site.j is (Configs.mCellSumY-1)
          up++
        if site.j is 0
          down++
      notZeroCount = 0 # 四条边不为0的个数
      for side in [left, up, right, down]
        if side is 0
          notZeroCount++
      # 超过2条边则不变色
      if notZeroCount > 2
        return false
      else if  (left + right + up + down > ((Configs.mCellSumX + Configs.mCellSumY) / 2))
        # 两边相加大于全部两条边的则表示其中有一边大于一半,因为有两边为0，所以四边相加应该不超过
        return false
      else
        # 变色
        return true

  ###
    获取某颜色单元块
  ###
  getGoalColorCells : (cells, color)->
    goalColorCells = []
    for i in [0...Configs.mCellSumX]
      for j in [0...Configs.mCellSumY]
        if cells[i][j].mColorIndex is color
          goalColorCells.push({'i':i, 'j':j})
    return goalColorCells

  ###
    判断某一点的周围(上下左右对角线八个点)是否有colorIndex一种颜色
  ###
  hasSideColor : (cells, i, j, colorIndex)->
    count = 0
    if @isEdge(i, j)
      count++
    if (i-1>=0) and (j-1>=0) and cells[i-1][j-1].mColorIndex is colorIndex
      return true
    else if (i-1>=0) and cells[i-1][j].mColorIndex is colorIndex
      count++
#      return true
    else if (i-1>=0) and (j+1<Configs.mCellSumY) and cells[i-1][j+1].mColorIndex is colorIndex
      return true
    else if (j-1>=0) and cells[i][j-1].mColorIndex is colorIndex
      count++
#      return true
    else if (j+1<Configs.mCellSumY) and cells[i][j+1].mColorIndex is colorIndex
      count++
#      return true
    else if (i+1<Configs.mCellSumX) and (j-1>=0) and cells[i+1][j-1].mColorIndex is colorIndex
      return true
    else if (i+1<Configs.mCellSumX) and cells[i+1][j].mColorIndex is colorIndex
      count++
#      return true
    else if (i+1<Configs.mCellSumX) and (j+1<Configs.mCellSumY) and cells[i+1][j+1].mColorIndex is colorIndex
      return true
    else if count > 1
      return true
    else
      return false

  ###
    判断周围是否有非目标颜色块
  ###
  hasNotSideColor : (cells, i, j, colorIndex) ->
    if @isEdge(i, j)
      return false
    if cells[i-1][j].mColorIndex isnt colorIndex
      return true
    else if cells[i][j-1].mColorIndex isnt colorIndex
      return true
    else if cells[i][j+1].mColorIndex isnt colorIndex
      return true
    else if cells[i+1][j].mColorIndex isnt colorIndex
      return true
    else
      return false

  ###
    判断（i, j）点是否在边界
  ###
  isEdge : (i, j)->
    if (i is 0) or (i is Configs.mCellSumX-1) or (j is 0) or ( j is Configs.mCellSumY-1)
      return true
    else
      return false

  # 得分计算公式
  scoringFormula : (n) ->
    score = if n is 1 then 100 else (100+100+(n-1)*20)*n/2
    return score

  # 从配置文件的公式中获取当前关卡的参数
  getFromFormula : (level, key, formula, defaultValue) ->
    # TODO
    level--
    bigLevel = Math.floor(level / 5)
    value = parseInt(Configs.mSettings[Keys.LEVELS][bigLevel][key])
    if  value <= 0
      return defaultValue # 返回默认值
    else
      i = level % 5
      jsonObj = Configs.mSettings
      sum = value
      try
        sum = eval(jsonObj[Keys.LEVELS][bigLevel][formula])
      catch e
        jlog.e e
        sum = value
      finally
        return sum

  # 获取当前关卡的目标颜色块数目
  getGoalColorSum : (level) ->
    return @getFromFormula(level, Keys.GOAL_SUM, Keys.SUM_FORMULA, 20)


  # 获取当前关卡的限制步数
  getLimitStep : (level) ->
    return @getFromFormula(level, Keys.LIMIT_STEP, Keys.STEP_FORMULA, false)

  # 获取当前关卡的目标分数限制
  getLimitScore : (level) ->
    return @getFromFormula(level, Keys.GOAL_SCORE, Keys.SCORE_FORMULA, false)


  # 获取当前关卡的时间限制，单位秒
  getLimitTime : (level) ->
    return @getFromFormula(level, Keys.LIMIT_TIME, Keys.TIME_FORMULA, false)


