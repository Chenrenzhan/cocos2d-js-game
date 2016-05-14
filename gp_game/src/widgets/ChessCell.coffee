###
  棋子单元格,坐标从左下角开始
###

@ChessCell = cc.Sprite.extend
  mColorIndex      :      0           # 颜色数组的下标
  mX               :      0           # 从游戏区域（棋盘）左下角起横向的下标
  mY               :      0           # 从游戏区域（棋盘）左下角起纵向的下标
  mIsSelect        :      false       # 是否选中
  mSelectEffect    :      null        # 选中特效
  mScanState       :      false       # 是否已经被扫过

  ctor : () ->
    @_super(resImg.cell)
#    ActionManager.shaderOutlineEffect(@)

  setParams : (colorIndex, x, y) ->
    @mColorIndex = colorIndex
    @mX = x
    @mY = y
    @initSize()
    @addInnerLove()

  initSize : ->
    @ignoreAnchorPointForPosition(false)
    @setAnchorPoint(cc.p(0, 0))
    @setScale(Configs.mCellScale)
    @setColor(Configs.mColors[@mColorIndex])
    @resetPosition()

  addInnerLove :  ->
    sprite = new cc.Sprite(resImg.little_love)
    sprite.setOpacity(150) # 设置透明度
    sprite.setPosition(cc.p(@width/2, @height/2))
    @addChild(sprite, 0)

  # 选中当前单元颜色块
  select : ->
    @mIsSelect = true
    # TODO 选中的效果，待定
#    @mSelectEffect = new cc.LabelTTF("选中")
#    @mSelectEffect.fontSize = 50
#    @mSelectEffect.fillStyle = cc.color(0, 0, 0, 255)
#    @mSelectEffect.setPosition(cc.p(@width/2, @height/2))

    @mSelectEffect = new cc.Sprite(resImg.halo)
    @mSelectEffect.setScale(@mSelectEffect.width / @width)
    @mSelectEffect.setPosition(cc.p(@width/2, @height/2))
    @mSelectEffect.runAction(ActionManager.selectCellAction())
#    ActionManager.shaderOutlineEffect(@mSelectEffect)
    @addChild(@mSelectEffect, 0)

#    ActionManager.shaderOutlineEffect(@)

  # 取消当前选中状态，并去除选中状态的特效
  unselect : ->
    if (not @mIsSelect) or (not @mSelectEffect?)
      return false
    @mSelectEffect.removeFromParent(true)
    @mIsSelect = false
#    ActionManager.removeOutlineEffect(@)

  setXY : (x, y) ->
    @mX = x
    @mY = y
  # 获取当前单元块下标
  getPoint : ->
    return cc.p(@mX, @mY)

  # 重置位置
  resetPosition : ->
    x = Configs.mBorderX + @mX * (Configs.mCellWidth + Configs.mCellGap)
    y = Configs.mBorderY + @mY * (Configs.mCellWidth + Configs.mCellGap)
    @setPosition(cc.p(x, y))

  # 重置颜色
  resetColor : (colorIndex, isAction) ->
    if isAction? and isAction
      action = ActionManager.turnCellAction(Configs.mColors[colorIndex])
      @runAction(action)
    else
      @setColor(Configs.mColors[colorIndex])
    @mColorIndex = colorIndex

#    @mColorIndexLabel.setString(colorIndex.toString())


@ChessCell.create = (colorIndex, x, y) ->
  chessCell = new ChessCell()
  chessCell.setParams(colorIndex, x, y)
  return chessCell

