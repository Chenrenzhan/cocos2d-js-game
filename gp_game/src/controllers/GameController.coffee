###
  游戏控制类
###

@GameController = cc.Class.extend
  mCurScene         :       null
  mGameState        :       null
  mIsNewGame        :       true
  mCurLevel         :       null
  mSelectLevel      :       null

  init: ->
    return true;

  setCurScene : (s) ->
    if @mCurScene isnt s
      if @mCurScene isnt null
        @mCurScene.onExit()
    @mCurScene = s
    if @mCurScene
      @mCurScene.onEnter()
      cc.director.runScene(s)

  getCurScene: ->
    return @mCurScene;

  runGame : ->
    jlog.i "run game"

  newGame : ->
    jlog.i "new game"

  option : ->
    jlog.i "option"

  about : ->
    jlog.i "about"

@GameController.getInstance = ->
  cc.assert(this._sharedGame, "Havn't call setSharedGame");
  if not @_sharedGame
    @_sharedGame = new GameController();
    if @_sharedGame.init()
      return @._sharedGame
  else
    return @_sharedGame
  return null

@GameController._sharedGame = null;
