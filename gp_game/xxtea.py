############################################################  
#                                                          #  
# The implementation of PHPRPC Protocol 3.0                #  
#                                                          #  
# xxtea.py                                                 #  
#                                                          #  
# Release 3.0.0                                            #  
# Copyright (c) 2005-2008 by Team-PHPRPC                   #  
#                                                          #  
# WebSite:  http://www.phprpc.org/                         #  
#           http://www.phprpc.net/                         #  
#           http://www.phprpc.com/                         #  
#           http://sourceforge.net/projects/php-rpc/       #  
#                                                          #  
# Authors:  Ma Bingyao <andot@ujn.edu.cn>                  #  
#                                                          #  
# This file may be distributed and/or modified under the   #  
# terms of the GNU Lesser General Public License (LGPL)    #  
# version 3.0 as published by the Free Software Foundation #  
# and appearing in the included file LICENSE.              #  
#                                                          #  
############################################################  
#  
# XXTEA encryption arithmetic library.  
#  
# Copyright (C) 2005-2008 Ma Bingyao <andot@ujn.edu.cn>  
# Version: 1.0  
# LastModified: Oct 5, 2008  
# This library is free.  You can redistribute it and/or modify it.  

# -*- coding: utf-8 -*-
  
import struct  
import sys
import os
import base64
  
_DELTA = 0x9E3779B9  
  
def _long2str(v, w):  
    n = (len(v) - 1) << 2  
    if w:  
        m = v[-1]  
        if (m < n - 3) or (m > n): return ''  
        n = m  
    s = struct.pack('<%iL' % len(v), *v)  
    return s[0:n] if w else s  
  
def _str2long(s, w):  
    n = len(s)  
    m = (4 - (n & 3) & 3) + n  
    s = s.ljust(m, "\0")  
    v = list(struct.unpack('<%iL' % (m >> 2), s))  
    if w: v.append(n)  
    return v  
  
def encrypt(str, key):  
    # str = base64.b64encode(str)
    if str == '': return str  
    v = _str2long(str, True)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    sum = 0  
    q = 6 + 52 // (n + 1)  
    while q > 0:  
        sum = (sum + _DELTA) & 0xffffffff  
        e = sum >> 2 & 3  
        for p in xrange(n):  
            y = v[p + 1]  
            v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            z = v[p]  
        y = v[0]  
        v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff  
        z = v[n]  
        q -= 1  
    return _long2str(v, False)  
  
def decrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, False)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    q = 6 + 52 // (n + 1)  
    sum = (q * _DELTA) & 0xffffffff  
    while (sum != 0):  
        e = sum >> 2 & 3  
        for p in xrange(n, 0, -1):  
            z = v[p - 1]  
            v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            y = v[p]  
        z = v[n]  
        v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff  
        y = v[0]  
        sum = (sum - _DELTA) & 0xffffffff  
    restr = _long2str(v, True) 
    return restr
    # return base64.b64decode(restr)

def readfile(filename):
    '''Print a file to the standard output.'''
    content = ''
    read = open(filename, 'r')
    lines = read.readlines()
    read.close()
    return content.join(lines)

def writeFile(filename, content) :
    file = open(filename, 'w+')
    file.write(content)
    file.close()
    
    
def inputFile():
    filename = ''
    type = 0 # 0--encrypt, 1--decrypt
    #ret = {'type': type, 'filename':filename}
    if len(sys.argv) == 1:
        type = 0 # default encrypt
        filename = input( "input filename: " )
    elif len(sys.argv) == 2:
        print(sys.argv[1])
        try :
            type = int(sys.argv[1])
        except: 
            type = 0
            filename = sys.argv[1]
            return {'type': type, 'filename':filename}
        if type != 0 or type != 1 : 
            type = 0 # default encrypt
            
        filename = input( "input filename: " )
        
    else :
        type = int(sys.argv[1])
        print(sys.argv[1])
        if type != 0 or type != 1 : 
            type = 0 # default encrypt
        filename = sys.argv[2]
    type = int(sys.argv[1])
    return {'type': type, 'filename':filename}
      
if __name__ == "__main__":  
    key = '<;d#@r%u?m*g$e,>'
    ret = inputFile()
    filename = ret['filename']
    type = ret['type']
    print('type' + str(type))
    content = readfile(filename)
    # print(content)
    if type == 0 : # encrypt
        content =  base64.b64encode(content)
        encrypt_content = encrypt(content, key)
        # decrypt_content = decrypt(encrypt_content, key)
        # print(decrypt_content)
        # writeFile(filename+'.xxtea.xxtea', decrypt_content)
        encrypt_content =  base64.b64encode(encrypt_content)
        writeFile(filename+'.xxtea', encrypt_content)
    elif type == 1  : # decrypt
        # content = content.decode('utf8')
        content = base64.b64decode(content)
        decrypt_content = decrypt(content, key)
        decrypt_content = base64.b64decode(decrypt_content)
        writeFile(filename+'.xxtea', decrypt_content)
    
    
    
    
    
    
    
    
    
    