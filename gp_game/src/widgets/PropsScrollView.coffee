###
  水平的道具滑动选择条
###

# 使用ccui.ScrollView来实现水平的滑动scrollView，ccui的性能不如cc
@PropsScrollView = cc.Node.extend
  mScrollView           :     null
  mLength               :     20
  mScrollTimeStamp      :     0            # 记录滑动时的时间戳，来实现滑动停止时的点击不响应
  mClickTimeStamp       :     0
  mLongClickAction      :     null        # 长按动画
  mIsAction             :     false
  mTouchTarget          :     null        # 触摸的target
  mTouchDownY           :     0            # 触摸开始时target Y轴坐标
  mTouchDownWidth       :     0            # 触摸开始时target 宽度

  ctor : ->
    @_super()
    # 半透明遮罩层
    layerMask = new cc.LayerColor(cc.color(0, 0, 0,150))
    layerMask.setContentSize(cc.winSize.width, 180)
    layerMask.attr
      anchorX : 0
      anchorY : 0
      x : 0
      y : 0
    @addChild layerMask, 10

    @initScrollView()

  initScrollView : ->
    self = @
    @mScrollView = new ccui.ScrollView()
    @mScrollView.setDirection(ccui.ScrollView.DIR_HORIZONTAL)
    @mScrollView.setTouchEnabled(true)
    @mScrollView.setBounceEnabled(true)
    @mScrollView.setInertiaScrollEnabled(true)
    if ccUtil.isNative()
      # 设置滚动条只有native才有效果，web会报错
      @mScrollView.setScrollBarEnabled(false)
    @mScrollView.setContentSize(cc.size(cc.winSize.width, 180))

    @mScrollView.attr
      anchorX : 0
      anchorY : 0
      x : 0
      y : 0
    @addChild(@mScrollView, 5);

    # 添加scrollView滑动事件
    @mScrollView.addEventListener (touch, eventType)->
      self.onScroll(touch, eventType)

    for i in [0...20]
      sprite = @getItemView(resImg.props, i)
      innerWidth = sprite.x + sprite.getContentSize().width / 2 + 20;
      innerHeight = @mScrollView.height;
      @mScrollView.setInnerContainerSize(cc.size(innerWidth, innerHeight));
      @mScrollView.addChild sprite

  getItemView : (res, index) ->
    sprite = new cc.Sprite(res)
    sprite.attr
      anchorX : 0.5
      anchorY : 0.5
      x : sprite.width / 2 + (sprite.width + 20) * index + 20
      y : sprite.height / 2 + 10
    label = new cc.LabelTTF(index.toFixed(0), "Helvetica", 50.0)
    label.x = sprite.width / 2
    label.y = sprite.height / 2
    sprite.addChild label, 0
    sprite.setTag(index)
    cc.eventManager.addListener @onListener().clone(), sprite
    return sprite

  # 处理点击item时间
  onListener : ->
    self = @
    return cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE,
      swallowTouches: false, # 必须设置为false，即不拦截事件，不然scroll滑动不响应
      onTouchBegan : (touch, event) ->
        target = event.getCurrentTarget()
        locationInNode = target.convertToNodeSpace(touch.getLocation())
        s = target.getContentSize()
        rect = cc.rect(0, 0, s.width, s.height)
        if (cc.rectContainsPoint(rect, locationInNode))
          @beginX = locationInNode.x
          @beginY = locationInNode.y
          @moveX = 5
          @moveY = 5
          @target = target
          if ccUtil.isNative()
            # getInnerContainerPosition 在web下没有
            @sx = self.mScrollView.getInnerContainerPosition().x
            self.mClickTimeStamp = TimeUtil.getTimeStamp()
            self.mTouchTarget = target
            self.scheduleOnce self.onLongClick
            , 0.6, "123"

          return true
        return false

      onTouchMoved : (touch, event) ->
        target = event.getCurrentTarget()
        if ccUtil.isNative()
          stamp = TimeUtil.getTimeStamp()
          # 按住不移动并且按住时间大于0.5秒才会触发长按效果
          if Math.abs(self.mScrollView.getInnerContainerPosition().x - @sx) > 5 or Math.abs(stamp - self.mClickTimeStamp) < 0.5
            self.unschedule self.onLongClick


      onTouchEnded : (touch, event) ->
        target = event.getCurrentTarget()
        locationInNode = target.convertToNodeSpace(touch.getLocation())
        endX = locationInNode.x
        endY = locationInNode.y
        t = TimeUtil.getTimeStamp()
        # 滑动距离大于@moveX或者滑动停止时间小于1秒，都不响应item点击事件
        if Math.abs(endX - @beginX) < @moveX and Math.abs(endY - @beginY) < @moveY and Math.abs(t - self.mScrollTimeStamp) > 1000
          # TODO 点击事件处理
          cc.log("sprite onTouchesEnded.. " + target.getTag())
        self.mScrollTimeStamp = 0
        if ccUtil.isNative()
          self.unschedule self.onLongClick
          self.onLongClickReverse()

  # 滑动事件
  onScroll : (touch, eventType) ->
    @mScrollTimeStamp = TimeUtil.getTimeStamp()

  # 长按动画效果，只有native有效果
  onLongClick :  ->
    if not @mIsAction
      @mTouchTarget.setLocalZOrder(100)
      @mIsAction = true
      @mY = @mTouchTarget.y
      @mWidth = @mTouchTarget.width
      moveBy = cc.moveBy(0.5, cc.p(0, 60))
      scaleBy = cc.scaleBy(0.5, 1.1)
      @mLongClickAction = cc.spawn(moveBy, scaleBy)
      @mTouchTarget.runAction @mLongClickAction

  onLongClickReverse : ->
    if @mIsAction
      try
        @mTouchTarget.stopAction(@mLongClickAction)
      catch err
        jlog.e err
      cy = @mTouchTarget.y
      cw = @mTouchTarget.getBoundingBox().width
      moveBy = cc.moveBy(0.3, cc.p(0, Math.round(@mY - cy)))
      scaleBy = cc.scaleBy(0.3, @mWidth * 1.0 / cw)
      @mIsAction = false
      @mTouchTarget.runAction cc.spawn(moveBy, scaleBy)

      @mTouchTarget.setLocalZOrder(100)
      jlog.i "onLongClickReverse   " + @mTouchTarget.getTag()

# 使用cc.TableView来实现水平的滑动scrollView，因为最左边的第一个总是忽然出现或者消失
@PropsTableView = cc.Node.extend
  mTableView        :       null
  mCellWidth        :       0
  mCellHeight       :       0

  ctor : ->
    @_super()
    layer = new cc.LayerColor(cc.color(0, 0, 0,150))
    layer.setContentSize(cc.winSize.width, 300)
    layer.attr
      anchorX : 0
      anchorY : 0
      x : 0
      y : 0
    @addChild layer, 20

    @initTableView()

  initTableView : ->
    sprite = new cc.Sprite(resImg.HelloWorld_png)
    @mCellWidth = sprite.width + 20
    @mCellHeight = sprite.height + 20
    width = cc.winSize.width - 20
    height = @mCellHeight
    jlog.d "width = " + width + "   ,   height = " + height
    @mTableView = new cc.TableView(@, cc.size(width, height))
    @mTableView.setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    @mTableView.x = -110;
    @mTableView.y = 20;
    #    @mTableView.attr =
    #      anchorX : 0.5
    #      anchorY : 0.5
    #      x       : 0
    #      y       : 0

    @mTableView.setDelegate(this)
    @addChild(@mTableView)
    @mTableView.reloadData()

  # override
  scrollViewDidScroll : (scrollview) ->
    #    cc.log scrollview
    # 使用时间戳来比较

  # override
  scrollViewDidZoom : (scrollview)  ->
    jlog.i "scrollViewDidZoom"

  # override
  updateCellAtIndex : (index) ->
    jlog.i "updateCellAtIndex  " + index

  tableCellTouched : (table, cell) ->
    jlog.i("cell touched at index: " + cell.getIdx())

  tableCellSizeForIndex : (table, idx) ->
    if idx is (@numberOfCellsInTableView() - 1)
      return cc.size(@mCellWidth - 20, 100)
    #    jlog.d "@mCellWidth = " + @mCellWidth + "   ,   @mCellHeight = " + @mCellHeight
    return cc.size(@mCellWidth, @mCellHeight)


  tableCellAtIndex : (table, idx) ->
    strValue = idx.toFixed(0)
    cell = table.dequeueCell()
    label
    if not cell
      cell = new cc.TableViewCell()

      sprite = new cc.Sprite(resImg.HelloWorld_png)
      sprite.setContentSize(60, 60)
      sprite.anchorX = 0
      sprite.anchorY = 0
      sprite.x = 0
      sprite.y = 0
      cell.addChild(sprite)

      label = new cc.LabelTTF(strValue, "Helvetica", 50.0)
      label.x = 100
      label.y = 100
      label.anchorX = 0
      label.anchorY = 0
      label.tag = 123
      cell.addChild(label)
    else
      label = cell.getChildByTag(123)
      label.setString(strValue)
    return cell

  numberOfCellsInTableView : (table) ->
    return 25

