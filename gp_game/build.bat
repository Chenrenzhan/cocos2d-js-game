copy ysdk-assets\* frameworks\runtime-src\proj.android-studio\app\assets\
del frameworks\runtime-src\proj.android-studio\app\assets\res /q /s 
del frameworks\runtime-src\proj.android-studio\app\assets\src /q /s 
xcopy res\* frameworks\runtime-src\proj.android-studio\app\assets\res /s /h /d /c /y /i 
xcopy src\* frameworks\runtime-src\proj.android-studio\app\assets\src /s /h /d /c /y /i
copy main.js frameworks\runtime-src\proj.android-studio\app\assets\main.js
copy project.json frameworks\runtime-src\proj.android-studio\app\assets\project.json
cd frameworks\runtime-src\proj.android-studio
gradle gp 2>../../../errlog
