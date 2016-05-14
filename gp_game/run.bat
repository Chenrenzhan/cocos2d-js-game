copy frameworks\runtime-src\proj.android-studio\app\build\outputs\apk\gp_game-debug_1.0_1.apk simulator\android\gp_game-debug_1.0_1.apk 
adb uninstall org.cocos2dx.js.gp_game
adb install -r simulator\android\gp_game-debug_1.0_1.apk
adb shell am start -n org.cocos2dx.js.gp_game/org.cocos2dx.gp_game.AppActivity