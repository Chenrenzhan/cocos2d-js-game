###
  本地数据持久化工具类
###

@DataUtil =
  mLS             :         cc.sys.localStorage

# 读取本地配置文件
  loadSettingsFile : (callback) ->
    cc.loader.loadTxt(resJson.settings, (err, data)->
      if err
        jlog.e err
      key = Keys.TEA_KEY
      str = Base64.decode(XxTea.decrypt(Base64.decode(data), key))
      obj = JSON.parse(str)
      callback(obj)
    )

  setUserId : (userId) ->
    @mLS.setItem(Keys.USER_ID, userId)

  getUserId : ->
    userId = @mLS.getItem(Keys.USER_ID)
#    @mLS.removeItem(Keys.USER_ID) #
    if StringUtil.isEmpty(userId)
      # TODO 后续再做随机生成 userID
      userId = "nochannelid" + (new Date().getTime())
      @setUserId(userId)
    return userId

  # 读取数据的json对象
  getData :  ->
    dataStr = @mLS.getItem(Keys.DATA)
#    @mLS.removeItem(Keys.DATA)
    if StringUtil.isEmpty(dataStr)
      obj = new Object()
      # TODO 渠道号
      obj[Keys.CHANNEL_ID] = "-1"
      obj[Keys.MUSIC] = true # 第一次初始化音乐为开
      obj[Keys.SOUND] = true # 第一次初始化音效为开
      @setData(obj)
      return obj
    # 解密
    jsonStr = Base64.decode(XxTea.decrypt(Base64.decode(dataStr), Keys.TEA_KEY))
    jsonObj = JSON.parse(jsonStr)
    return jsonObj

  # 写入json对象数据，进行持久化
  setData : (json) ->
    if not StringUtil.isString(json)
      json = JSON.stringify(json)
    # 加密
    jsonStr = Base64.encode(XxTea.encrypt(Base64.encode(json), Keys.TEA_KEY))
    @mLS.setItem(Keys.DATA, jsonStr)

  # 保存数据
  saveData : ->
    if Configs.mData?
      @setData(Configs.mData)

  # 保存关卡得分
  saveLevelScore : (level, score) ->
    if not Configs.mData?
      return null
    data = Configs.mData
    if not ccUtil.isObjectNotNull(data[Keys.LEVEL_HIGHEST_SCORE])
      data[Keys.LEVEL_HIGHEST_SCORE] = []
    scores = data[Keys.LEVEL_HIGHEST_SCORE]
    if scores.length < level
      for i in [0..(level - scores.length)]
        scores.push(0)
    if scores[level-1] < score
      scores[level-1] = score
    if level > data[Keys.CURRENT_LEVEL]
      data[Keys.CURRENT_LEVEL] = level
    @saveData()

  # 保存背景音乐设置
  saveMusicSettings : (isOpen) ->
    if not Configs.mData?
      return null
    Configs.mData[Keys.MUSIC] = isOpen
    @saveData()
  # 保存背景音效设置
  saveSoundSettings : (isOpen) ->
    if not Configs.mData?
      return null
    Configs.mData[Keys.SOUND] = isOpen
    @saveData()

  # 添加数据, 注意，不是cc.cyc.localStorage的setItem,而是加到data中
  setDataItem : (key, value) ->
    if not Configs.mData? or not key?
      return false
    Configs.mData[key] = value
    @saveData()
  # 获取数据, 注意，不是cc.cyc.localStorage的setItem,而是从data中
  getDataItem : (key, defaultValue) ->
    if not Configs.mData[key]?
      Configs.mData[key] = defaultValue
      @saveData()
      return defaultValue
    else
      return Configs.mData[key]

  refreshDataFromNet : (userId) ->
    self = @
    BmobHelper.getLevelHighestScore(userId, (scores)->
      if scores? and scores.length > 0
        Configs.mData[Keys.LEVEL_HIGHEST_SCORE] = scores
        self.saveData()
    )
