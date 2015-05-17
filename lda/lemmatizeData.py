#!/usr/bin/python

# lemmatize caption data in input file line-by-line, and write it to output file

import sys
import re
from nltk.stem.wordnet import WordNetLemmatizer

infilename = sys.argv[1]
outfilename = sys.argv[2]

infile = open(infilename, 'r')
outfile = open(outfilename, 'w')
pattern = '^(\S+)#(\d+)\t(.*)'
lmtzr = WordNetLemmatizer()

for line in infile:
    tokens = re.match(pattern, line)
    caption = tokens.group(3)
    words = caption.split()
    words_processed = []
    for word in words:
        word = word.lower()
        noun = str(lmtzr.lemmatize(word))
        verb = str(lmtzr.lemmatize(word, 'v'))
        if (noun != word):
            out = noun
        elif (verb != word):
            out = verb
        else:
            out = word
        words_processed.append(out)
    caption_processed = ' '.join(words_processed)
    line_processed = "%s#%s\t%s\n" % (tokens.group(1), tokens.group(2), caption_processed)
    outfile.write(line_processed)

