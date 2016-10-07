###
  音频管理类
###

@AudioManager =
  mBgMusic        :       resAudio.bg_music     # 背景音乐
  mSuccessAudio   :       resAudio.success      # 成功音效
  mFailsAudio     :       resAudio.fails        # 失败音效
  mTurnAudio      :       resAudio.overturn     # 目标颜色翻转音效
  mClickAudio     :       resAudio.click        # 点击音效
  mTranspAudio    :       resAudio.transp       # 换位，即交换颜色块
  mLoadingFinish  :       resAudio.loading_finish     # 加载界面加载完成播放音效
  mStartGameAudio :       resAudio.start_game         # 开始游戏

  mIsBgOlaying    :       false                 # 背景音乐是否正在播放

  isBgmPlaying : ->
    # isMusicPlaying 可能不work，再试试willPlayMusic()，正在播放则返回false
    return cc.audioEngine.isMusicPlaying()

  # 进入游戏时初始化背景音乐应调用此方法
  initBgm : ->
    if Configs.mIsBgmPlay
      @playBgm()
    else
      @stopBgm()

  playBgm : ->
    if not @mIsBgOlaying
      cc.audioEngine.playMusic(@mBgMusic, true)
#      @saveIsBgmPlay(true)
      @mIsBgOlaying = true


  pauseBgm : ->
    if @mIsBgOlaying
      cc.audioEngine.pauseMusic()
      @mIsBgOlaying = false

  resumeBgm : ->
    if not @mIsBgOlaying
      cc.audioEngine.resumeMusic()
      @mIsBgOlaying = true

  stopBgm : ->
    if Configs.mIsBgmPlay
      cc.audioEngine.stopMusic()
#      @saveIsBgmPlay(false)
      @mIsBgOlaying = false

  saveIsBgmPlay : (isBgmPlay) ->
    Configs.mIsBgmPlay = isBgmPlay
    DataUtil.saveMusicSettings(isBgmPlay)

  # 保存音效开关
  saveIsSound : (isOpen) ->
    DataUtil.saveSoundSettings(isOpen)


  playWinAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mSuccessAudio, false)
  playFailsAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mFailsAudio, false)
  playTurnAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mTurnAudio, false)
  playClickAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mClickAudio, false)
  playTranspkAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mTranspAudio, false)

  playLoadingFinish : ->
    if Configs.mData[Keys.SOUND]
      @finishAudioId = cc.audioEngine.playEffect(@mLoadingFinish, false)
  stopLoadingFinish : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.stopEffect(@finishAudioId)

  playStartGameAudio : ->
    if Configs.mData[Keys.SOUND]
      cc.audioEngine.playEffect(@mStartGameAudio, false)