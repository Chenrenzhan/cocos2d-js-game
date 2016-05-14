###
  bmob后台数据存储工具类
  # 创建道具属性数据库表，Props(props_id, price, name, description)（道具ID， 价格， 名字， 描述），道具ID：0--魔术棒，1--回退一步， 2--增加5步
  # 创建道具数量数据库表， PropsSum(user_id, props_id, sum)（用户ID， 道具ID，数量）
  # 创建用户信息数据库表， User(user_id, channel_id, coin)（用户ID， 渠道ID， 金币总数， 拥有道具数量）
  # 创建记录成绩数据库表， Score(user_id, level, highest_score, win_times, fail_times)（关卡， 最高成绩， 通关次数，失败次数）
###

Bmob.initialize(Keys.BMOB_APPLICATION_ID, Keys.BMOB_REST_API_KEY);

@BmobHelper =
  # Bmob后端数据库相关
  USER_TABLE          :         "UserTable"
  USER_ID             :         "user_id"
  CHANNEL_ID          :         "channel_id"
  COIN                :         "coin"
  PROPS_TABLE        :         "Props"
  PROPS_ID            :         "props_id"
  PRICE               :         "price"
  DESCRIPTION         :         "description"
  SCORE_TABLE         :         "Score"
  LEVEL               :         "level"
  HIGHEST_SCORE       :         "highest_score"
  WIN_TIMES           :         "win_times"
  FAIL_TIMES          :         "fail_times"
  PROPS_SUM_TABLE    :         "PropsSum"
  PROPS_SUM               :         "sum"


  # 添加一条新用户信息 User(user_id, channel_id, Score, coin)（用户ID， 渠道ID，关联成绩表， 金币总数， 拥有道具数量）
  addUser : (userId, channelId) ->
    channelId = channelId.toString()
    User = Bmob.Object.extend(@USER_TABLE)
    query = new Bmob.Query(User)
    query.equalTo(@USER_ID, userId)
    self = @
    query.find().then( (users) ->
      # 查找成功，返回符合查找条件的数据的数组
      jlog.i "query sucess"
      jlog.cc users
      if(users.length == 0)
        self.addNewUser(userId, channelId)
      else
        users[0].set(@CHANNEL_ID, channelId)
        users[0].save()
    , (error) ->
      # 失败,表示存在，则插入新数据
      jlog.i "query fail"
      self.addNewUser(userId, channelId)
    )
  addNewUser : (userId, channelId) ->
     User = Bmob.Object.extend(@USER_TABLE)
     user = new User()
     user.set(@USER_ID, userId)
     user.set(@CHANNEL_ID, channelId)
     user.set(@COIN, 0)
     user.save().then( (data)->
        # 保存成功返回创添加成功的一条数据
       jlog.i ( "User data id "  + data.id)
       jlog.cc data
     , (error) ->
       jlog.i ( "add data error "  + error)
       jlog.cc error
     )

  # 根据道具ID获取该道具数量
  getPropsSum : (userId, propsId) ->
    sum = 0
    self = @
    UserProps = Bmob.Object.extend(@PROPS_SUM_TABLE)
    query = new Bmob.Query(UserProps)
    query.equalTo(@USER_ID, userId)
    query.equalTo(@PROPS_ID, propsId)
    query.find().then(
      (results) ->
        if(results.length > 0)
          sum = results[0].get(self.PROPS_SUM)
      (error) ->
        jlog.cc error
    )
    return sum

  # 购买道具
  buyProps : (userId, propsId, sum) ->
    self = @
    UserProps = Bmob.Object.extend(@PROPS_SUM_TABLE)
    query = new Bmob.Query(UserProps)
    query.equalTo(@USER_ID, userId)
    query.equalTo(@PROPS_ID, propsId)
    query.find().then(
      (results) ->
        jlog.cc results
        if(results.length > 0)
          _sum = results[0].get(self.PROPS_SUM)
          jlog.cc results[0].get(self.PROPS_SUM)
          sum += _sum
          jlog.i "sum = " + sum
          results[0].set(self.PROPS_SUM, sum)
          results[0].save()
        else
          self.addNewPropsSum(userId, propsId, sum)
      (error) ->
        self.addNewPropsSum(userId, propsId, sum)
    )
  # 添加一条新的道具数据
  addNewPropsSum : (userId, propsId, sum) ->
    UserProps = Bmob.Object.extend(@PROPS_SUM_TABLE)
    userProps = new UserProps()
    jlog.cc userId
    userProps.set(@USER_ID, userId)
    userProps.set(@PROPS_ID, propsId)
    userProps.set(@PROPS_SUM, sum)
    userProps.save().then(
      (results) ->
        jlog.cc results
      (error) ->
        jlog.cc error
    )

  # 保存游戏通关至服务器
  saveGameWin : (userId, level, score) ->
    self = @
    Score = Bmob.Object.extend(@SCORE_TABLE)
    query = new Bmob.Query(Score)
    query.equalTo(@USER_ID, userId)
    query.equalTo(@LEVEL, level)
    query.find().then(
      (results) ->
        if(results.length > 0)
          winTime = results[0].get(self.WIN_TIMES) + 1
          results[0].set(self.WIN_TIMES, winTime)
          highScore = results[0].get(self.HIGHEST_SCORE)
          if highScore < score
            results[0].set(self.HIGHEST_SCORE, score )
          results[0].save()
        else
          self.addNewLevelScore(userId, level, score, true)
      (error) ->
        self.addNewLevelScore(userId, level, score, true)
    )
  # 上传游戏失败至服务器
  saveGameFail : (userId, level, score) ->
    self = @
    Score = Bmob.Object.extend(@SCORE_TABLE)
    query = new Bmob.Query(Score)
    query.equalTo(@USER_ID, userId)
    query.equalTo(@LEVEL, level)
    query.find().then(
      (results) ->
        if(results.length > 0)
          fail = results[0].get(self.FAIL_TIMES) + 1
          results[0].set(self.FAIL_TIMES, fail)
          results[0].save()
        else
          self.addNewLevelScore(userId, level, score, false)
      (error) ->
        self.addNewLevelScore(userId, level, score, false)
    )
  # 添加一条新的关卡成绩记录
  addNewLevelScore : (userId, level, score, isWin) ->
    jlog.i "userId = " + userId + "    ;   level = " + level
    Score = Bmob.Object.extend(@SCORE_TABLE)
    scoreTable = new Score()
    scoreTable.set(@USER_ID, userId)
    scoreTable.set(@LEVEL, level)
    scoreTable.set(@HIGHEST_SCORE, score)
    if isWin
      scoreTable.set(@WIN_TIMES, 1)
      scoreTable.set(@FAIL_TIMES, 0)
    else
      scoreTable.set(@WIN_TIMES, 0)
      scoreTable.set(@FAIL_TIMES, 1)
    scoreTable.save().then(
      (result) ->
        jlog.cc result
      (error) ->
        jlog.cc error
    )

  # 获取关卡最高得分
  getLevelHighestScore : (userId, callback) ->
    array = null
    self = @
    Score = Bmob.Object.extend(@SCORE_TABLE)
    query = new Bmob.Query(Score)
    query.equalTo(@USER_ID, userId)
    query.select(@LEVEL, @HIGHEST_SCORE)
    query.descending(@LEVEL)
    query.find().then(
      (results) ->
        array = []
        for result in results
            level = result.get(self.LEVEL)
            score = result.get(self.HIGHEST_SCORE)
            array[level-1] = score
        callback(array)
      (error) ->
        jlog.cc error
        array = null
    )







