/* XXTEA encryption arithmetic library.
 *
 * Copyright (C) 2006 Ma Bingyao <andot@ujn.edu.cn>
 * Version:      1.5
 * LastModified: Dec 9, 2006
 * This library is free.  You can redistribute it and/or modify it.
 */

function long2str(v, w) {
  var vl = v.length;
  var n = (vl - 1) << 2;
  if (w) {
    var m = v[vl - 1];
    if ((m < n - 3) || (m > n)) return null;
    n = m;
  }
  for (var i = 0; i < vl; i++) {
    v[i] = String.fromCharCode(v[i] & 0xff,
        v[i] >>> 8 & 0xff,
        v[i] >>> 16 & 0xff,
        v[i] >>> 24 & 0xff);
  }
  if (w) {
    return v.join('').substring(0, n);
  }
  else {
    return v.join('');
  }
}

function str2long(s, w) {
  var len = s.length;
  var v = [];
  for (var i = 0; i < len; i += 4) {
    v[i >> 2] = s.charCodeAt(i)
        | s.charCodeAt(i + 1) << 8
        | s.charCodeAt(i + 2) << 16
        | s.charCodeAt(i + 3) << 24;
  }
  if (w) {
    v[v.length] = len;
  }
  return v;
}

function xxtea_encrypt(str, key) {
  if (str == "") {
    return "";
  }
  var v = str2long(str, true);
  var k = str2long(key, false);
  if (k.length < 4) {
    k.length = 4;
  }
  var n = v.length - 1;

  var z = v[n], y = v[0], delta = 0x9E3779B9;
  var mx, e, p, q = Math.floor(6 + 52 / (n + 1)), sum = 0;
  while (0 < q--) {
    sum = sum + delta & 0xffffffff;
    e = sum >>> 2 & 3;
    for (p = 0; p < n; p++) {
      y = v[p + 1];
      mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
      z = v[p] = v[p] + mx & 0xffffffff;
    }
    y = v[0];
    mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
    z = v[n] = v[n] + mx & 0xffffffff;
  }

  return long2str(v, false);
}

function xxtea_decrypt(str, key) {
  if (str == "") {
    return "";
  }
  var v = str2long(str, false);
  var k = str2long(key, false);
  if (k.length < 4) {
    k.length = 4;
  }
  var n = v.length - 1;

  var z = v[n - 1], y = v[0], delta = 0x9E3779B9;
  var mx, e, p, q = Math.floor(6 + 52 / (n + 1)), sum = q * delta & 0xffffffff;
  while (sum != 0) {
    e = sum >>> 2 & 3;
    for (p = n; p > 0; p--) {
      z = v[p - 1];
      mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
      y = v[p] = v[p] - mx & 0xffffffff;
    }
    z = v[n];
    mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
    y = v[0] = v[0] - mx & 0xffffffff;
    sum = sum - delta & 0xffffffff;
  }

  return long2str(v, true);
}




function encode64(input) {
  var keyStr = "ABCDEFGHIJKLMNOP" +
      "QRSTUVWXYZabcdef" +
      "ghijklmnopqrstuv" +
      "wxyz0123456789+/" +
      "=";
  input = escape(input);
  var output = "";
  var chr1, chr2, chr3 = "";
  var enc1, enc2, enc3, enc4 = "";
  var i = 0;

  do {
    chr1 = input.charCodeAt(i++);
    chr2 = input.charCodeAt(i++);
    chr3 = input.charCodeAt(i++);

    enc1 = chr1 >> 2;
    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
    enc4 = chr3 & 63;

    if (isNaN(chr2)) {
      enc3 = enc4 = 64;
    } else if (isNaN(chr3)) {
      enc4 = 64;
    }

    output = output +
        keyStr.charAt(enc1) +
        keyStr.charAt(enc2) +
        keyStr.charAt(enc3) +
        keyStr.charAt(enc4);
    chr1 = chr2 = chr3 = "";
    enc1 = enc2 = enc3 = enc4 = "";
  } while (i < input.length);

  return output;
}

function decode64(input) {
  var keyStr = "ABCDEFGHIJKLMNOP" +
      "QRSTUVWXYZabcdef" +
      "ghijklmnopqrstuv" +
      "wxyz0123456789+/" +
      "=";
  var output = "";
  var chr1, chr2, chr3 = "";
  var enc1, enc2, enc3, enc4 = "";
  var i = 0;

  // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
  var base64test = /[^A-Za-z0-9\+\/\=]/g;
  if (base64test.exec(input)) {
    console.error("There were invalid base64 characters in the input text.\n" +
        "Valid base64 characters are A-Z, a-z, 0-9, '+', '/', and '='\n" +
        "Expect errors in decoding.");
  }
  input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

  do {
    enc1 = keyStr.indexOf(input.charAt(i++));
    enc2 = keyStr.indexOf(input.charAt(i++));
    enc3 = keyStr.indexOf(input.charAt(i++));
    enc4 = keyStr.indexOf(input.charAt(i++));

    chr1 = (enc1 << 2) | (enc2 >> 4);
    chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
    chr3 = ((enc3 & 3) << 6) | enc4;

    output = output + String.fromCharCode(chr1);

    if (enc3 != 64) {
      output = output + String.fromCharCode(chr2);
    }
    if (enc4 != 64) {
      output = output + String.fromCharCode(chr3);
    }

    chr1 = chr2 = chr3 = "";
    enc1 = enc2 = enc3 = enc4 = "";

  } while (i < input.length);

  return unescape(output);
}

var fs = require("fs");
var key = '<;d#@r%u?m*g$e,>'
function writeFile(filename, data){
  // 2、写文件
  fs.writeFile(filename, data, function (error) {
    if (error) {
      // 出现错误
    }
    // 继续操作
  });

}
function readFile(filename, callback){
  fs.readFile(filename, function (error, fileData) {
    if (error) {
      // 出现错误
    }
    // 操作fileData
    //console.dir(fileData.toString());
    callback(fileData.toString());
  });
}

function encryptFile(deFilename, enFilename){
  readFile(deFilename, function(fileData){
    var encrypt = encode64(xxtea_encrypt(encode64(fileData), key));
    writeFile(enFilename, encrypt);
  });
}

function decryptFile(enFilename, deFilename){
  readFile(enFilename, function(fileData){
    var decrypt = decode64(xxtea_decrypt(decode64(fileData), key));
    jsonObj = JSON.parse(decrypt);
    //console.dir(jsonObj);
    json = jsonObj;
    for(var i = 0; i < 10; ++i){
      console.log(eval(jsonObj.levels[0].sumFormula));
    }

    console.dir(jsonObj.levels[0].colors);
    writeFile(deFilename, decrypt);
  });
}

// 异步读写文件，不可以连续进行加密后解密
//encryptFile('settings.json', 'res/json/settings.json.txt');
decryptFile('res/json/settings.json.txt','settings.json.de');

//var str = "{}";
//var enstr = encode64(xxtea_encrypt(encode64(str), key));
//var destr = decode64(xxtea_decrypt(decode64(enstr), key));
//console.log(enstr);
//console.log(destr);
