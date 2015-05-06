import random
import os
import subprocess
import re
import shlex
import sys
from pprint import pprint as pprint
from collections import defaultdict

if __name__ == "__main__":
    p = subprocess.Popen(['ls','-a','finishedImages'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()

    lsParts = out.split("\n")
    print lsParts	
    #nameList = []
    nameList = defaultdict()

    for line in lsParts:
        if line is not '':
            matchObj = re.match(r'([A-z]+)\d+\.', line, re.M|re.I)
            if matchObj:
                tagName = matchObj.group(1)
                #print tagName
                #nameList[].append(matchObj.group(1))
                if tagName in nameList:
                    #print "Already exists!"
                    nameList[tagName].append(line)
                else:
                    #print "New key"
                    nameList[tagName] = []
                    nameList[tagName].append(line)

    #sortedList = sorted(set(nameList))
    #print sortedList
    #print nameList
	percent=float(sys.argv[1])
	train_test_split=defaultdict(dict)

    train = open("trainingData.txt", "w+")
    test = open("testingData.txt", "w+")

    for key,value in nameList.iteritems():
        random.shuffle(value)
        value_length=len(value)
        number_of_train_values=round(float(value_length)*percent/100,0)
        number_of_train_values=int(number_of_train_values) 	
        train_values=value[0:(number_of_train_values)]
        test_values=value[number_of_train_values:(value_length)]
        for val in train_values:
            train.write(val + "\n")
        for val in test_values:
            test.write(val + "\n")
        train_test_split[key]={'train':train_values,'test':test_values}
        	#print "______"
        	#print ",".join(value)
        	#print "*********"
        pprint(train_test_split)

    train.close()
    test.close()
