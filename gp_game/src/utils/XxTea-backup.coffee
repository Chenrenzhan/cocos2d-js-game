###
  XXTea加密算法
###

@XxTea =
  long2str : (v, w) ->
    vl = v.length
    n = (vl - 1) << 2
    if (w)
      m = v[vl - 1]
      if ((m < n - 3) || (m > n)) then return null
      n = m

    for i in [0...vl]
      v[i] = String.fromCharCode(v[i] & 0xff,v[i] >>> 8 & 0xff, v[i] >>> 16 & 0xff, v[i] >>> 24 & 0xff)
    if (w)
      return v.join('').substring(0, n)
    else
      return v.join('')

  str2long : (s, w) ->
    len = s.length;
    v = [];
    i = 0
    while i < len
      v[i >> 2] = s.charCodeAt(i) | s.charCodeAt(i + 1) << 8 | s.charCodeAt(i + 2) << 16 | s.charCodeAt(i + 3) << 24;
      i += 4
    if (w)
      v[v.length] = len;
    return v

  encrypt : (str, key) ->
    if str? or str is ""
      return ""
    v = @str2long(str, true)
    k = @str2long(key, false)
    if (k.length < 4)
      k.length = 4
    n = v.length - 1
    z = v[n]
    y = v[0]
    delta = 0x9E3779B9
    mx
    e
    p
    q = Math.floor(6 + 52 / (n + 1))
    sum = 0
    while (0 < q--)
      sum = sum + delta & 0xffffffff;
      e = sum >>> 2 & 3;
      for p in [0...n]
        y = v[p + 1];
        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z)
        z = v[p] = v[p] + mx & 0xffffffff
      y = v[0];
      mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
      z = v[n] = v[n] + mx & 0xffffffff;
    return @long2str(v, false)

  decrypt : (str, key) ->
    if (str? or str == "")
      return ""
    v = @str2long(str, false)
    k = @str2long(key, false)
    if (k.length < 4)
      k.length = 4
    n = v.length - 1
    z = v[n - 1]
    y = v[0]
    delta = 0x9E3779B9
    mx
    e
    p
    q = Math.floor(6 + 52 / (n + 1))
    sum = q * delta & 0xffffffff
    while (sum != 0)
      e = sum >>> 2 & 3
      for p in [n...0]
        z = v[p - 1]
        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z)
        y = v[p] = v[p] - mx & 0xffffffff
    z = v[n]
    mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z)
    y = v[0] = v[0] - mx & 0xffffffff
    sum = sum - delta & 0xffffffff
    return @long2str(v, true)
