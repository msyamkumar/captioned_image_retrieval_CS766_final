# Generate filenames of training data

import numpy as np
import os
import matplotlib.pyplot as plt
import cv2

# File containing filenames of our old image
#input_filename = '/home/bjiashen/builds/caffe/data/flickr_style/test.txt'
input_filename = '/home/bjiashen/captioned-image-retrieval/data/Flickr_8k.testImages.txt'
output_filename = '/home/bjiashen/captioned-image-retrieval/caffenet/test.txt'

# Where our new images are stores
root = '/home/bjiashen/captioned-image-retrieval/data/Flicker8k_crops'

def filenames(filename):
    "Generate filenames contained in a file `filename`"
    with open(filename) as fid:
        for line in fid:
            yield line

with open(output_filename, 'w') as fid:
    for filename in filenames(input_filename):
        name, ext = os.path.splitext(filename)
        for ind in range(10):
            dump = os.path.join(root, '%s_%i%s' % (name, ind, ext))
            fid.write(dump)
