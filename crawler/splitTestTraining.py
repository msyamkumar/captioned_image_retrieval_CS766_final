import random
import os
import subprocess
import re
import shlex
from collections import defaultdict

if __name__ == "__main__":
    print "Hello, World!"

    p = subprocess.Popen(['ls','-a','finishedImages'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()

    lsParts = out.split("\n")

    #nameList = []
    nameList = defaultdict()

    for line in lsParts:
        if line is not '':
            matchObj = re.match(r'([A-z]+)\d+\.', line, re.M|re.I)
            if matchObj:
                tagName = matchObj.group(1)
                print tagName
                #nameList[].append(matchObj.group(1))
                if tagName in nameList:
                    print "Already exists!"
                    nameList[tagName].append(line)
                else:
                    print "New key"
                    nameList[tagName] = []
                    nameList[tagName].append(line)

    #sortedList = sorted(set(nameList))
    #print sortedList
    #print nameList


    for key,value in nameList.iteritems():
        print key
        random.shuffle(value)
        print "______"
        print ",".join(value)
        print "*********"
