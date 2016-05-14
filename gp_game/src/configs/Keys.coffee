###
  数据持久化key的常量键值
###

@Keys =
  staticClass    :     true    # 静态类
  TEA_KEY         :      "<;d#@r%u?m*g$e,>"
  # Bmob配置
  BMOB_APPLICATION_ID :     "f2b224c5e8af32ec69a6539916b56f0f"
  BMOB_REST_API_KEY   :     "30a6e18d0073f8fc84bf00064adda06f"

  # 配置文件settings的相关key
  LEVELS              :         "levels"              # 所有关卡信息，数组，一大关卡，包含10个小关卡
  COLORS              :         "colors"              # 每一大关卡的颜色数组
  GOAL_SUM            :         "goal_sum"            # 每一大关开始一关的目标颜色块数目
  GOAL_SCORE          :         "goal_score"          # 目标分数限制，值为-1时表示，该大关没有这一限制条件
  LIMIT_STEP          :         "limit_step"          # 限制步数
  LIMIT_TIME          :         "limit_time"          # 时间限制
  SUM_FORMULA         :         "sum_formula"         # 目标颜色块计算公式
  STEP_FORMULA        :         "step_formula"        # 限制步数计算公式
  TIME_FORMULA        :         "time_formula"        # 限制时间计算公式
  SCORE_FORMULA       :         "scroce_formula"      # 得分限制计算公式


  # 本地数据持久化 cc.sys.localStorage
  USER_ID             :         "user_id"               # 用户ID，用来区分不同用户，可以保存不同用户的信息
  DATA                :         ""                      # 使用userId来做键值，持久化的数据信息，经过加密json字符串

  # 本地持久化数据存储的json对象的key
  CHANNEL_ID          :         "channel_id"            # 用户账号的渠道ID ， -1 表示没有渠道
  MUSIC               :         "music"                 # 背景音乐打开或者关闭
  SOUND               :         "sound"                 # 音效打开或者关闭
  LEVEL_HIGHEST_SCORE :         "level_highest_score"   # 保存每一关的最高得分，数组[]类型
  CURRENT_LEVEL       :         "current_level"         # 当前关卡数

  # 道具ID：0--魔术棒，1--回退一步， 2--增加5步
  MAGIC_WAND            :         0
  BACK_ONE_STEP         :         1
  INCREASE_5_STEP       :         2



