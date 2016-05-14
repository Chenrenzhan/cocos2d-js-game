###
  关卡卡牌
###

@LevelCard = cc.LayerColor.extend
  mColor                :             null          # 卡片颜色
  mLevel                :             1              # 卡片关卡
  mCallback             :             null           # 点击回调

  ctor : (color, level) ->
    @_super(color)
    @mColor = color
    @mLevel = level
    @init()
    @addLevelCardLabel(level)
#    @addScoreLabel(323232)
#    @cardShake()
#    @addMarkLayer()

  init : ->
    @setContentSize(250, 114)
    @ignoreAnchorPointForPosition(false)
    self = @
    TouchUtil.onClick(@, ->
      self.mCallback(self.mLevel)
    )

  addLevelCardLabel : (level) ->
    if not @ring?
      @ring = new cc.Sprite(resImg.number_ring)
      @addChild(@ring, 0)
      levelLabel = new cc.LabelTTF(level.toString())
      #    levelLabel.fontSize = 40
      levelLabel.attr
        fontSize : 60
        x : @ring.width / 2
        y : @ring.height / 2
      @ring.addChild(levelLabel, 0)

#    return @ring

  # 已经通关的关卡，最高分数显示
  addScoreLabel : (score)->
    if not score?
      score = "0"
    @label = new cc.LabelTTF(score)
    @label.attr
      fontSize : 40
      x : @width / 2
      y : @height / 2 - 10
    @addChild(@label, 0)

  # 添加遮罩层
  markLayer : (isMark)->
    if isMark
      if not @mark?
        @mark = new cc.LayerColor(cc.color(69, 69, 69, 169))
        @mark.setContentSize(@getContentSize())
        @addChild(@mark, 10)

        TouchUtil.onClick(@mark, ->
          # 点击遮罩层不进行响应
          return false
        )
      else
        @mark.setLocalZOrder(10)
    else if @mark?
      @mark.setLocalZOrder(-1)

  # 摇晃
  cardShake : ->
    @shake = @runAction(ActionManager.cardShake())
  # 停止摇晃
  stopCardShake : ->
    if @shake?
      @stopAction(@shake)


  # 打开关卡的关卡数label显示
  openLevel : (isOpen) ->
    @markLayer(not isOpen)
    if isOpen
      @stopCardShake()
      @ring.attr
        scale : 0.5
        anchorX : 0
        anchorY : 1
        x : 10
        y : @height - 10
    else
      @ring.attr
        scale : 1.0
        anchorX : 0.5
        anchorY : 0.5
        x : @width / 2
        y : @height / 2

  # 下一个可以打开的关卡
  nextOpenLevel : ->
    @openLevel(false)
    @markLayer(false)
    @cardShake()

  # 点击回调
  setOnClickCallback : (callback) ->
    @mCallback = callback

  # 设置显示最高分数
  setScore : (score) ->
    @addScoreLabel(score)


