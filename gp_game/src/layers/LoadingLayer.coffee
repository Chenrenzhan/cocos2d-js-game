###
  加载资源显示的layer
###

@LoadingLayer = LayerBase.extend
  mLogoSprite               :         null
  mTipSprite                :         null
  mloadingProgressLabel     :         null

  ctor: ->
    @_super()
    @addBg()
    @addLogo()
    @addTip()
    @addLoadingLabel()

  addBg : ->
    if @mBgFrame isnt null
      @mBgFrame.removeFromParent(false)
    @mBgFrame = new cc.LayerColor cc.color(255, 255, 255, 255)
    @addChild @mBgFrame

  addLogo : ->
    @mLogoSprite = new cc.Sprite(resImg.logo)
    @mLogoSprite.attr
      x : cc.winSize.width / 2
      y : cc.winSize.height / 2
    @addChild(@mLogoSprite)

  addTip : ->
    @mTipSprite = new cc.Sprite(resImg.loading_tip)
    @mTipSprite.attr
      x : cc.winSize.width - 50
      y : cc.winSize.height - 50
    @addChild(@mTipSprite)
    @mTipSprite.runAction(ActionManager.rotateAction())

  addLoadingLabel : ->
    label = new cc.LabelTTF("正在拼命加载...")
    label.fontSize = 30
    label.fillStyle = cc.color(0, 0, 0, 255)
    label.attr
      x : cc.winSize.width / 2 - 30
      y : @mLogoSprite.y - 150
    @addChild(label)

    @mloadingProgressLabel = new cc.LabelTTF("0%")
    @mloadingProgressLabel.fontSize = 30
    @mloadingProgressLabel.fillStyle = cc.color(0, 0, 0, 255)
    @mloadingProgressLabel.attr
      x : label.x + label.width / 2 + 30
      y : label.y
    @addChild(@mloadingProgressLabel)

  setPercent : (percent) ->
    @mloadingProgressLabel.string = percent + "%"

