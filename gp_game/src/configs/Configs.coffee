###
  属性配置工具类
###

_Configs = cc.Class.extend
  mAndroidPackageName :     "org/cocos2dx/gp_game"
  mIsBgmPlay          :     true    # 背景音乐
  mLoadResourceDelay  :     0.5      # 延迟加载资源，单位秒

  mSettings           :     null      # 配置文件的json对象
  mLocalData          :     null      # 本地数据持久化保存对象
  mUserId             :     null      # 用户标识ID

  mColors             :     [cc.color(253,61,83), cc.color(252,200,186), cc.color(241,30,105),cc.color(250,163,167)
                             cc.color(251,140,138), cc.color(219,27,81)]
  mColorSum           :     6     # 颜色种类数目
  mCellSumMax         :     9     # 一边最大的单元块数目
  mCellSumX           :     9     # 棋盘X轴单元格数目，最大为9个
  mCellSumY           :     9     # 棋盘Y轴单元格数目，最大为9个
  mCellImgWidth       :     100   # 单元格图片的边长
  mCellWidth          :     0     # 棋盘颜色块单元格边长
  mCellScale          :     0     # 单元颜色块缩放比例
  mCellGap            :     0     # 单元格之间的间距
  mBorderX            :     0     # 左右边距
  mBorderY            :     0     # 上下边距

  mStyle              :     ["Joy", "Sweet", "Romantic", "Meek", "Elegant"]


  ctor : ->
    # Setup the resolution policy and design resolution size
    # 在这里设置设计的尺寸，避免在初始化时使用cc.winSize出现尺寸不一的情况
    if(ccUtil.isNative())
      cc.view.setDesignResolutionSize(720, 1280, cc.ResolutionPolicy.EXACT_FIT);
    else
      cc.view.setDesignResolutionSize(720, 1280, cc.ResolutionPolicy.SHOW_ALL);
    @mCellWidth = cc.winSize.width / @mCellSumMax
    @mCellScale = @mCellWidth / @mCellImgWidth
    @setCellSum(@mCellSumX, @mCellSumY)

    DataUtil.loadSettingsFile( (jsonObj)=>
      @mSettings = jsonObj
    )

    @mUserId = DataUtil.getUserId()
    Keys.DATA = @mUserId
    @mData = DataUtil.getData()
    @mIsBgmPlay = @mData[Keys.MUSIC]
    jlog.cc @mData
    jlog.cc @mUserId
    BmobHelper.addUser(@mUserId, @mData[Keys.CHANNEL_ID])
#    BmobHelper.buyProps(@mUserId, 1, 5)

    # 从服务器更新本地数据
    DataUtil.refreshDataFromNet(@mUserId)

    # 原生系统才可以，友盟登录统计
    if ccUtil.isNative()
      umeng.MobClickCpp.profileSignIn(@mUserId, @mData[Keys.CHANNEL_ID])

  # 重置单元格数目，x乘y
  setCellSum : (sumX, sumY) ->
    @mCellSumX = sumX
    @mCellSumY = sumY
#    @mBorderX = (cc.winSize.width - @mCellWidth * @mCellSumX - @mCellGap * (@mCellSumX - 1)) / 2
#    @mBorderY = (cc.winSize.width - @mCellWidth * @mCellSumY - @mCellGap * (@mCellSumY - 1)) / 2

  # 根据当前关卡设置颜色
  setColors : (level) ->
    level -= 1
    # TODO
    colors = @mSettings[Keys.LEVELS][Math.floor(level / 5)][Keys.COLORS]
    @mColors = null
    @mColors = []
    for c in colors
      color = cc.color(c.r, c.g, c.b, c.a)
      @mColors.push(color)

@Configs = new _Configs()
