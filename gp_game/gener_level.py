#!/usr/bin/env python
# coding: utf-8

def writeFile(filename, content) :
    file = open(filename, 'w+')
    file.write(content)
    file.close()

def generator() :
	str = ""
	for( i = 1; i <= 60; ++i ) :
		str += "level-" + str(i) + ",关卡-" + str(i) + "\n"
	return str

 if __name__ == "__main__": 
 	str = generator()
 	writeFile("level.csv", str)