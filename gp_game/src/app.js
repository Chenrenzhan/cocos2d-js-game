
var HelloWorldLayer = cc.Layer.extend({
    sprite:null,
    ctor:function () {
        //////////////////////////////
        // 1. super init first
        this._super();

         bgFrame = new cc.LayerColor(cc.color(255, 255, 255, 255));
        this.addChild(bgFrame, 0);

        /////////////////////////////
        // 2. add a menu item with "X" image, which is clicked to quit the program
        //    you may modify it.
        // ask the window size
        var size = cc.winSize;

        /////////////////////////////
        // 3. add your codes below...
        // add a label shows "Hello World"
        // create and initialize a label
        var helloLabel = new cc.LabelTTF("Hello World", "Arial", 38);
        // position the label on the center of the screen
        helloLabel.fillStyle = cc.color(0, 0, 0, 255);
        helloLabel.x = size.width / 2;
        helloLabel.y = size.height / 2 + 200;
        // add the label as a child to this layer
        this.addChild(helloLabel, 5);

        // add "HelloWorld" splash screen"
        this.sprite = new cc.Sprite(resImg.HelloWorld_png);
        this.sprite.attr({
            x: size.width / 2,
            y: size.height / 2
        });
        this.addChild(this.sprite, 0);
        cc.log(this.sprite.getPosition());
        self = this;
        // 创建一个事件监听器 OneByOne 为单点触摸
        var listener1 = cc.EventListener.create({
            event: cc.EventListener.TOUCH_ONE_BY_ONE,
            swallowTouches: true,                       // 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
            onTouchBegan: function (touch, event) {     //实现 onTouchBegan 事件回调函数
                var target = event.getCurrentTarget();  // 获取事件所绑定的 target
                // 获取当前点击点所在相对按钮的位置坐标
                var locationInNode = target.convertToNodeSpace(touch.getLocation());
                var s = target.getContentSize();
                var rect = cc.rect(0, 0, s.width, s.height);
                if (cc.rectContainsPoint(rect, locationInNode)) {       // 点击范围判断检测
                    cc.log("sprite began... x = " + locationInNode.x + ", y = " + locationInNode.y);
                    target.opacity = 180;
                    return true;
                }
                return false;
            },
            onTouchMoved: function (touch, event) {         // 触摸移动时触发
                // 移动当前按钮精灵的坐标位置
                var target = event.getCurrentTarget();
                var delta = touch.getDelta();
                target.x += delta.x;
                target.y += delta.y;
            },
            onTouchEnded: function (touch, event) {         // 点击事件结束处理
                var target = event.getCurrentTarget();
                cc.log("sprite onTouchesEnded.. ");
                target.setOpacity(255);
                //if (target == sprite2) {                    // 重新设置 ZOrder，显示的前后顺序将会改变
                //    sprite1.setLocalZOrder(100);
                //} else if (target == sprite1) {
                //    sprite1.setLocalZOrder(0);
                //}
                //var scaleBy = cc.scaleBy(0.5, 1.5);
                var moveTo = cc.moveTo(1, cc.p(380, 380));
                var fun = ccUtil.callFunc(function(){
                    jlog.d("target  width = " + target.getBoundingBox().width);
                    cc.log(self.sprite.getPosition());
                }, "ddd");
                target.runAction(cc.sequence(moveTo, fun));

            }
        });
        cc.eventManager.addListener(listener1, this.sprite);

        var adLabel = new cc.LabelTTF("广告");
        adLabel.fillStyle = cc.color(0, 0, 0, 255);
        adLabel.fontSize = 50;
        var adItem = new cc.MenuItemLabel(adLabel, function(){
            jlog.i("广告");

            if(ccUtil.isAndroid()){
                // 调用java
                jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/BaiduAdHelper", "showAd",
                    "(Ljava/lang/String;Ljava/lang/String;)V", "title", "hahahahha");
            }

        }, this);
        adItem.attr = {
            x : 200,
            y : 200
        };

        var adMenu = new cc.Menu();
        adMenu.x = cc.winSize.width / 2;
        adMenu.y = cc.winSize.height - 200;
        adMenu.addChild(adItem, 10);
        //menu.addChild(menuLabel1, 10);
        this.addChild(adMenu, 10);

        var label = new cc.LabelTTF("微信登录");
        label.fillStyle = cc.color(0, 0, 0, 255);
        label.fontSize = 50;
        var menuLabel = new cc.MenuItemLabel(label, function(){
            jlog.i("微信登录");
            if(ccUtil.isAndroid()){
                // 调用java
                jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "loginWX", "()V");
                jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "queryUserInfo", "()V");
            }

        }, this);
        menuLabel.attr = {
            x : 200,
            y : 200
        };
        var menu = new cc.Menu();
        menu.x = cc.winSize.width - menuLabel.width;
        menu.y = cc.winSize.height / 2;
        menu.addChild(menuLabel, 10);
        //menu.addChild(menuLabel1, 10);
        this.addChild(menu, 10);

        var label1 = new cc.LabelTTF("QQ登录");
        label1.fillStyle = cc.color(0, 0, 0, 255);
        label1.fontSize = 50;
        var menuLabel1 = new cc.MenuItemLabel(label1, function(){
            jlog.i("QQ登录");

            if(ccUtil.isAndroid()){
                // 调用java
                jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "loginQQ", "()V");
                jsb.reflection.callStaticMethod(Configs.mAndroidPackageName + "/YSDKHelper", "queryUserInfo", "()V");
            }

        }, this);
        menuLabel1.attr = {
            x : 110,
            y : 110
        };


        var menu1 = new cc.Menu();
        menu1.x = 100;
        menu1.y = cc.winSize.height / 2;
        //menu1.addChild(menuLabel, 10);
        menu1.addChild(menuLabel1, 10);
        this.addChild(menu1, 10);

        return true;
    }
});

var HelloWorldScene = cc.Scene.extend({
    onEnter:function () {
        this._super();
        var layer = new HelloWorldLayer();
        this.addChild(layer);
    }
});

