###
  Base64编码解码实现
###

@Base64 =
  map : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
  encode : (input) ->
    input = escape(input)
    output = ""
    chr1
    chr2
    chr3 = ""
    enc1
    enc2
    enc3
    enc4 = ""
    i = 0
    while(true)
      chr1 = input.charCodeAt(i++)
      chr2 = input.charCodeAt(i++)
      chr3 = input.charCodeAt(i++)
      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63
      if (isNaN(chr2))
        enc3 = enc4 = 64
      else if (isNaN(chr3))
        enc4 = 64
      output = output +
          @map.charAt(enc1) +
          @map.charAt(enc2) +
          @map.charAt(enc3) +
          @map.charAt(enc4)
      chr1 = chr2 = chr3 = ""
      enc1 = enc2 = enc3 = enc4 = ""
      if i >= input.length
        break
    return output
  decode : (input) ->
    output = ""
    chr1
    chr2
    chr3 = ""
    enc1
    enc2
    enc3
    enc4 = ""
    i = 0
    # remove all characters that are not A-Z, a-z, 0-9, +, /, or =
    base64test = /[^A-Za-z0-9\+\/\=]/g;
    if (base64test.exec(input))
      jlog.e("There were invalid base64 characters in the input text.\n" +
          "Valid base64 characters are A-Z, a-z, 0-9, '+', '/', and '='\n" +
          "Expect errors in decoding.");
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "")
    while(true)
      enc1 = @map.indexOf(input.charAt(i++))
      enc2 = @map.indexOf(input.charAt(i++))
      enc3 = @map.indexOf(input.charAt(i++))
      enc4 = @map.indexOf(input.charAt(i++))
      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4
      output = output + String.fromCharCode(chr1)
      if (enc3 != 64)
        output = output + String.fromCharCode(chr2)
      if (enc4 != 64)
        output = output + String.fromCharCode(chr3)
      chr1 = chr2 = chr3 = ""
      enc1 = enc2 = enc3 = enc4 = ""
      if i >= input.length
        break
    return unescape(output)