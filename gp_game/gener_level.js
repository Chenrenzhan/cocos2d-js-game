
var fs = require("fs");
function writeFile(filename, data){
    // 2、写文件
    fs.writeFile(filename, data, function (error) {
        if (error) {
            // 出现错误
        }
        // 继续操作
    });

}

function gener_level(){
    str = "";
    for(var i = 1; i <= 60; ++i){
        str += "level-" + i + ",关卡-" + i + "\n"
    }
    return str
}

writeFile("level.csv", gener_level())