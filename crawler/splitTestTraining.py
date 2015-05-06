import os
import subprocess
import re
import shlex

if __name__ == "__main__":
    print "Hello, World!"

    p = subprocess.Popen(['ls','-a','finishedImages'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()

    lsParts = out.split("\n")

    nameList = []

    for line in lsParts:
        if line is not '':
            matchObj = re.match(r'([A-z]+)\d+\.', line, re.M|re.I)
            if matchObj:
                nameList.append(matchObj.group(1))

    sortedList = sorted(set(nameList))
    print sortedList

    grepStr = sortedList[0]

    proc1 = subprocess.Popen(shlex.split('ls', '-a', 'finishedImages'),stdout=subprocess.PIPE)
    proc2 = subprocess.Popen(shlex.split(grepStr),stdin=proc1.stdout,
                             stdout=subprocess.PIPE,stderr=subprocess.PIPE)

    proc1.stdout.close() # Allow proc1 to receive a SIGPIPE if proc2 exits.
    out,err=proc2.communicate()

    print out
