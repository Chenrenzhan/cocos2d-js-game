###
  进入游戏加载资源进度页面
###
@LoaderScene = cc.Scene.extend
  _interval         :     null
  _className        :     "LoaderScene"
  cb                :     null
  target            :     null
  mLoadingLayer     :     null

  init: ->
    self = @
    self.mLoadingLayer = new LoadingLayer()
    self.addChild(self.mLoadingLayer)
    return true

  onEnter : ->
    self = @
    cc.Node.prototype.onEnter.call self
    self.schedule self._startLoading, 0.3

  onExit : ->
    self = @
    cc.Node.prototype.onExit.call self
#    self.mLoadingLayer.setProgress 0

  initWithResources : (resources, cb, target)->
    resources = [resources] if cc.isString(resources)
    @resources = resources or []
    @cb = cb
    @target = target

  updatePercent : (loadedCount, count) ->
    percent = (loadedCount / count * 100) | 0
    percent = Math.min percent, 100
    # TODO 跟新进度条
    @mLoadingLayer.setPercent(percent)
    cc.log percent

  _startLoading : ->
    self = @
    self.unschedule self._startLoading
    res = self.resources
    self._length = res.length
    self._count = 0
    # 延迟加载资源
    self.schedule ->
      cc.loader.load res, (result, count, loadedCount) ->
        loadedCount += 1
        percent = (loadedCount / count * 100) | 0
        percent = Math.min percent, 100
        # TODO 设置进度条百分比
        self.mLoadingLayer.setPercent(percent)
      , -> self.cb.call(self.target) if self.cb
    , Configs.mLoadResourceDelay

  _updateTransform: ->
    @_renderCmd.setDirtyFlag cc.Node._dirtyFlags.transformDirty
#    @mLoadingLayer.setDirtyFlag cc.Node._dirtyFlags.transformDirty

LoaderScene.preload = (resources, cb, target) ->
  _cc = cc
  if not _cc.loaderScene
    _cc.loaderScene = new LoaderScene()
    _cc.loaderScene.init()
    cc.eventManager.addCustomListener cc.Director.EVENT_PROJECTION_CHANGED, -> _cc.loaderScene._updateTransform()
  _cc.loaderScene.initWithResources resources, cb, target
  cc.director.runScene _cc.loaderScene
  return _cc.loaderScene






