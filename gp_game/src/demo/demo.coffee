
@colors = ["#0000ff",  "#ff7f50", "#7fff00", "#deb887", "#8a2be2", "#d2691e", "#6495ed", "#a52a2a2a"]
@colorsSum = 6
@targetColor = 0;  #  目标颜色
@timer = null # 计时

@targetColorSum = 0 # 当前目标颜色数目

# 形状
@mShape =
  checked : true
  i : 9
  j : 9
# 目标色块数
@mBlock =
  checked : true
  sum : 20
# 步数
@mStep =
  checked : true
  sum : 30
# 时间限制
@mTime =
  checked : false
  sum : 100

@cells = []
#目标颜色位置
@targetColorCells = []

@cellFlag =
  color : 0
  hadScan : false # 是否已经被扫过

@cell =
  color : 0
  cellFlags : []


@ready = ->
#  initParam()
#  initArray()
  generateChessBoard()
#  play()

@initArray = ->
  @cells = null
  @cells = []
  for i in [0...@mShape.i]
    @cells[i] = null
    @cells[i] = []

  @targetColorCells = null
  @targetColorCells = []

#初始化参数
@initParam = ->
  @targetColorSum = 0

  @mShape.checked = $('#cb_shape').is(':checked')
  @mShape.i = parseInt($('#shape_i').val())
  @mShape.j = parseInt($('#shape_j').val())

  @mBlock.checked = $('#cb_block').is(':checked')
  @mBlock.sum = parseInt($('#block_sum').val())

  @mStep.checked = $('#cb_step').is(':checked')
  @mStep.sum = parseInt($('#step_sum').val())

  @mTime.checked = $('#cb_time').is(':checked')
  @mTime.sum = parseInt($('#time_sum').val())

@generateChessBoard = ->
  initParam()
  initArray()
  table = $('<table align=\"center\"></table>');
  for i in [0...@mShape.i]
    tr=$('<tr></tr>');
    for j in [0...@mShape.j]
      td=$('<td></td>');
      td.addClass('true');
      td_id = 'td-' + i + '-' + j;
      td.attr('id',td_id);
      td.addClass("cell");
      td.appendTo(tr);
    tr.appendTo(table);

  $('#container').html("");
  table.appendTo($('#container'));
  randColor()
  play()

@randColor = ->
  random = Math.random() * (@colorsSum-1)
  randomInt = Math.floor(random)
  @targetColor = randomInt
  $('#reset').css('background', 'black')
  $('#reset').css('background', colors[randomInt])
  for i in [0...@mShape.i]
    for j in [0...@mShape.j]
      random = Math.random() * (@colorsSum - 1)
      randomInt = Math.floor(random)
      cl = JSON.parse(JSON.stringify(@cell))
      cl.color = randomInt
      for k in [0...@colorsSum]
        cf = JSON.parse(JSON.stringify(@cellFlag))
        cf.color = k
        cl.cellFlags[k] = cf
      @cells[i][j] = cl
      id ="#td-" + i + "-" + j
      $(id).css("background",colors[randomInt])
      $(id).html(randomInt)
  scanChange()

  adjustTargetColor()
  checkOneColor(@targetColor, true)
  resetScanState(@targetColor)

  countColorSum(@targetColor)
#  console.log "@targetColorCells.length 1111111111 = " + @targetColorCells.length

  adjustTargetColor()

  $('#score').html(0)
  if @mTime.checked
    $('#countdown').html(@mTime.sum)
  else
    $('#countdown').html(0)
  if not @mStep.checked
    $('#step').html(0)
  else
    $('#step').html(@mStep.sum)

  # 计数开始
  startTimer()

###
  统计一种颜色数目
###
@countColorSum = (color)->
  count = 0
  @targetColorCells = null
  @targetColorCells = []
  for i in [0...@mShape.i]
    for j in [0...@mShape.j]
      if @cells[i][j].color is color
        @targetColorCells.push({'i':i, 'j':j})
        count++
  return count

###
  调整目标颜色数目
###
@adjustTargetColor = ->
  countColorSum(@targetColor)
#  if @targetColorCells.length > (@mShape.i * @mShape.j)
#    generateChessBoard()
  console.log "@targetColorCells.length 000 = " + @targetColorCells.length
  if @targetColorCells.length < @mBlock.sum
    # 添加目标颜色块
    addTargetColorBlock()
  else if @targetColorCells.length > @mBlock.sum
    # 删除目标颜色块
    removeTargetColorBlock()
  @targetColorSum = @targetColorCells.length
  console.log "@targetColorCells.length = " + @targetColorCells.length
#  adjustTargetColor()

###
  添加一块目标颜色块
###
@addTargetColorBlock = ->
  count = 0
  while @targetColorCells.length < @mBlock.sum
    i = Math.floor(Math.random() * @mShape.i)
    j = Math.floor(Math.random() * @mShape.j)
#  for i in [0...@mShape.i]
#    for j in [0...@mShape.j]
    if @cells[i][j].color isnt @targetColor and not hasAdjoinColor(i, j, @targetColor)
      id = structId(i, j)
      setColor(id, @colors[@targetColor], @targetColor)
      @targetColorCells.push({'i':i, 'j':j})
    else
      count++
      if count > (@mShape.i * @mShape.j * 2)
        generateChessBoard()
#      dif--
#      if dif is 0
#        return true

###
  删除一块目标颜色块
###
@removeTargetColorBlock = ->
#  console.log " @removeTargetColorBlock @targetColorCells.length 000 = " + @targetColorCells.length
  count = 0
  while @targetColorCells.length > @mBlock.sum
    random = Math.random() * @targetColorCells.length
    randomInt = Math.floor(random)
    location = @targetColorCells[randomInt]
#    console.log "hasNotColorSide(location.i, location.j, @targetColor) : " + hasNotColorSide(location.i, location.j, @targetColor)
    if hasNotColorSide(location.i, location.j, @targetColor)
      id = structId(location.i, location.j)
      setColor(id, @colors[@colorsSum-1], @colorsSum-1)
      @targetColorCells.splice(randomInt, 1)
    else
      count++
      if count > (@mShape.i * @mShape.j * 2)
        generateChessBoard()
#      console.log " @removeTargetColorBlock @targetColorCells.length = " + @targetColorCells.length

###
  判读周围是否有非目标颜色块
###
@hasNotColorSide = (i, j, colorIndex) ->
  i = parseInt(i)
  j = parseInt(j)
#  console.log "@@hasNotColorSide(i, j) : " + i + " , " + j
  if isSide(i, j)
    return false
  if (i-1>=0) and @cells[i-1][j].color isnt colorIndex
#    direct++
    return true
  else if (j-1>=0) and @cells[i][j-1].color isnt colorIndex
#    direct++
    return true
  else if (j+1<@mShape.j) and @cells[i][j+1].color isnt colorIndex
#    direct++
    return true
  else if (i+1<@mShape.i) and @cells[i+1][j].color isnt colorIndex
#    direct++
    return true
#  else if direct > 1
#    console.log "direct : " + direct
#    return true
  else
#    console.log "direct : " + direct
#    console.log "@hasAdjoinColor(i, j) : " + i + " , " + j
    return false

###
  判断某一点的周围是否有同一种颜色
###
@hasAdjoinColor = (i, j, color)->
  direct = 0
  if isSide(i, j)
    direct++
#  console.log "direct 0000 : " + direct
  if (i-1>=0) and (j-1>=0) and @cells[i-1][j-1].color is color
    return true
  else if (i-1>=0) and @cells[i-1][j].color is color
    direct++
#    return true
  else if (i-1>=0) and (j+1<@mShape.j) and @cells[i-1][j+1].color is color
    return true
  else if (j-1>=0) and @cells[i][j-1].color is color
    direct++
#    return true
  else if (j+1<@mShape.j) and @cells[i][j+1].color is color
    direct++
#    return true
  else if (i+1<@mShape.i) and (j-1>=0) and @cells[i+1][j-1].color is color
    return true
  else if (i+1<@mShape.i) and @cells[i+1][j].color is color
    direct++
#    return true
  else if (i+1<@mShape.i) and (j+1<@mShape.j) and @cells[i+1][j+1].color is color
    return true
  else if direct > 1
#    console.log "direct : " + direct
    return true
  else
#    console.log "direct : " + direct
#    console.log "@hasAdjoinColor(i, j) : " + i + " , " + j
    return false

# 判断（i, j）是否在边界
@isSide = (i, j) ->
  if (i is 0) or (i is @mShape.i-1) or (j is 0) or ( j is @mShape.j-1)
    return true
  else
    return false

@play = ->
  isDown = false
  downColor = "#000000"
  downId = ""
  upColor = "#000000"
  upId = ""
  for i in [0...@mShape.i]
    for j in [0...@mShape.j]
      id ="#td-" + i + "-" + j
      $(id).bind(
        selectstart : (e) ->
          return false
        mousedown : (e) ->
          isDown = true
          downId = getIdFromEvent(e)
          return false

#        mousemove : (e) ->
#          console.log "mousemove"
        mouseup : (e) ->
          if not isDown then return false
          isDown = false
          upId = getIdFromEvent(e)
          if not isAdjacent(downId, upId) then return false
          downColor = getColor(downId)
          upColor = getColor(upId)
          downTag = getTag(downId)
          upTag = getTag(upId)
          if downColor isnt upColor
            setColor(downId, upColor, upTag)
            setColor(upId, downColor, downTag)
            stepIncreate()

            checkOneColor(downTag, true)
            checkOneColor(upTag, true)

            resetScanState(downTag)
            resetScanState(upTag)

            if isGameComplete()
              gameComplete()
      )

@getIdFromEvent = (event) ->
  return event.currentTarget.id

@getTag = (id) ->
  return $("#" + id).html()

@getColor = (id) ->
  return $("#" + id).css("background")

@setColor = (id, color, tag) ->
  $("#" + id).css("background", color)
  $("#" + id).html(tag)
  ids = id.split("-")
  @cells[ids[1]][ids[2]].color = tag

@structId = (i, j) ->
  return "td-" + i + "-" + j


###
  是否相邻
###
@isAdjacent = (downId, upId) ->
  down = downId.split('-')
  up = upId.split('-')
  if (down[1] == up[1] and Math.abs(down[2] - up[2]) == 1) or (down[2] == up[2] and Math.abs(down[1] - up[1]) == 1)
    return true
  else
    return false

###
  开始计时
###
@startTimer = ->
  if not @mTime.checked
    $('#countdown').html(0)
    try
      clearInterval(@timer);
    catch err
      console.error(err)
    @timer = setInterval ->
      t = parseInt($('#countdown').html())
      t++
      $('#countdown').html(t)
    , 1000
  else
    $('#countdown').html(@mTime.sum)
    try
      clearInterval(@timer);
    catch err
      console.error(err)
    @timer = setInterval ->
      t = parseInt($('#countdown').html())
      t--
      $('#countdown').html(t)
      if t <= 0
        gameOver()
        try
          clearInterval(@timer);
        catch err
          console.error(err)
    , 1000

###
  步骤增加
###
@stepIncreate = (sum = 1) ->
#  $('#step')
  if not @mStep.checked
    count = parseInt($('#step').html())
    count += sum
    $('#step').html(count)
  else
    count = parseInt($('#step').html())
    count -= sum
    $('#step').html(count)
    if count <= 0
      gameOver()

###
  游戏结束
###
@gameOver = ->
  msg = "游戏结束\n"
#  $('#countdown').html(0)
#  $('#score').html(0)
#  $('#step').html(0)
  if @mStep.checked
    msg += "剩余步骤为: " + $('#step').html() + "\n"
  else
    msg += "使用步数为： " + $('#step').html() + "\n"
  if @mTime.checked
    msg += "剩余时间为: " + $('#countdown').html() + "\n"
  else
    msg += "使用时间为： " + $('#countdown').html() + "\n"
  msg += "得分为： " + $('#score').html() + "\n"
  alert(msg)

###
  判断游戏是否通关
###
@isGameComplete = ->
  if @targetColorSum < @mShape.i * @mShape.j
    return false
  return true

###
  游戏通关
###
@gameComplete = ->
  msg = "游戏通关\n"
  if @mStep.checked
    msg += "剩余步骤为: " + $('#step').html() + "\n"
  else
    msg += "使用步数为： " + $('#step').html() + "\n"
  if @mTime.checked
    msg += "剩余时间为: " + $('#countdown').html() + "\n"
  else
    msg += "使用时间为： " + $('#countdown').html() + "\n"
  msg += "得分为： " + $('#score').html() + "\n"
  alert(msg)

###
  扫描变色块
###
@scanChange = ->
#  checkOneColor(@targetColor, false)
  for k in [0...@colorsSum]
    if k is @targetColor
      continue
    checkOneColor(k, false)

    checkOneColor(@targetColor, false)

  for c in [0...@colorsSum]
    resetScanState(c)

###
  重置扫描状态
###
@resetScanState = (colorIndex)->
#  for k in [0...@colorsSum]
  for i in [0...@mShape.i]
    for j in [0...@mShape.j]
      @cells[i][j].cellFlags[colorIndex].hadScan = false

###
  检测一种颜色变色情况
###
@checkOneColor = (colorIndex, isPlay) ->
  colorIndex = parseInt(colorIndex)
  for i in [0...@mShape.i]
    for j in [0...@mShape.j]
      if @cells[i][j].cellFlags[colorIndex].hadScan || parseInt(@cells[i][j].color) is colorIndex
        @cells[i][j].cellFlags[colorIndex].hadScan = true
        continue
      scanCells = scanOneCell(i, j, colorIndex)
      if judgeChange(scanCells)
        changeColors(scanCells, colorIndex, isPlay)

###
 以一个起点扫描
###
@scanOneCell = (i, j, colorIndex) ->
  i = parseInt(i)
  j = parseInt(j)
  colorIndex = parseInt(colorIndex)
  queue = [] # 队列
  scanCells = [] # 已经扫过的节点

  @cells[i][j].cellFlags[colorIndex].hadScan = true
  queue.push({'i': i, 'j': j})
  # 广度优先算法搜索
  while queue.length > 0
    site = queue.shift()
    x = site.i
    y = site.j
    # 左
    if (y - 1 >= 0) and (parseInt(@cells[x][y - 1].color) isnt colorIndex) and (not @cells[x][y - 1].cellFlags[colorIndex].hadScan)
      @cells[x][y - 1].cellFlags[colorIndex].hadScan = true
      queue.push({'i': x, 'j': y - 1})
    # 上
    if (x - 1 >= 0) and (parseInt(@cells[x - 1][y].color) isnt colorIndex) and (not @cells[x - 1][y].cellFlags[colorIndex].hadScan)
      @cells[x - 1][y].cellFlags[colorIndex].hadScan = true
      queue.push({'i': x - 1, 'j': y})
    # 右
    if (y + 1 < @mShape.j) and (parseInt(@cells[x][y + 1].color) isnt colorIndex) and (not @cells[x][y + 1].cellFlags[colorIndex].hadScan)
      @cells[x][y + 1].cellFlags[colorIndex].hadScan = true
      queue.push({'i': x, 'j': y + 1})
    # 下
    if (x + 1 < @mShape.i) and (parseInt(@cells[x + 1][y].color) isnt colorIndex) and (not @cells[x + 1][y].cellFlags[colorIndex].hadScan)
      @cells[x + 1][y].cellFlags[colorIndex].hadScan = true
      queue.push({'i': x + 1, 'j': y})

    scanCells.push(site)
  return scanCells

###
  分开判断变色
###
@judgeChange = (scanCells) ->
# 判断在边界的数目
  minEdge = if @mShape.i > @mShape.j then @mShape.j else @mShape.i
  if scanCells.length < minEdge / 2 + 1
    return true
  else
    # 可能变色， 判断边界数目
    left = 0
    right = 0
    up = 0
    down = 0
    for l in [0...scanCells.length]
      s = scanCells[l]
      if s.j is 0
        left++
      if s.j is (@mShape.j-1)
        right++
      if s.i is 0
        up++
      if s.i is (@mShape.i-1)
        down++
    # 超过三条边则不变色
    if left > 0 and right > 0 and up > 0 and down > 0
    # 四条边，不变色
      return false
    else if((left > 0 and right > 0 and up > 0 ) and (left > 0 and right > 0 and down > 0) and (left > 0 and up > 0 and down > 0) and (right > 0 and up > 0 and down > 0))
      # 三条边不变色
      return false
    else if(left + right + up + down > ((@mShape.i + @mShape.j) / 2))
      # 两边相加大于8的则表示其中有一边大于一半,因为有两边为0，所以四边相加应该不超过8
      return false
    else
      # 变色
      return true

###
  改变颜色
###
@changeColors = (scanCells, color, isPlay) ->
  n = scanCells.length
  color = parseInt(color)
  if isPlay and color is @targetColor
    @targetColorSum += scanCells.length

    # 得分
    score = parseInt($('#score').html())
    score += if n is 1 then 100 else (100+100+(n-1)*20)*n/2
    $('#score').html(score)

  for s in scanCells
    i = s.i
    j = s.j
    @cells[i][j].color = color
    setColor(structId(i, j), @colors[color], color)
