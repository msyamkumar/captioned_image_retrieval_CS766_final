# Generate 10 crops of Flickr8K data

import numpy as np
import os
import matplotlib.pyplot as plt
import cv2

dir_im = '../data/Flicker8k_Dataset'
dir_out = '../data/Flicker8k_crops'

im_filenames = os.listdir(dir_im)

for im_filename in im_filenames:

    path = os.path.join(dir_im, im_filename)

    im = cv2.imread(path)
    im = cv2.resize(im, (256, 256))

    # Get five crops in 4 corners + center
    nonflipped_crops = (im[y1:y1+227, x1:x1+227]
        for (x1, y1) in [(0, 0), (0, 29), (29, 0), (29, 29), (15, 15)])

    #all_crops = (im for im in [x, x[:, ::-1]] for x in nonflipped_crops)
    # Get five non-flipped and five flipped crops
    all_crops = (im
        for nonflipped_crop in nonflipped_crops
        for im in [nonflipped_crop, nonflipped_crop[:, ::-1]]
        )

    for ind, crop in enumerate(all_crops):
        name, ext = os.path.splitext(im_filename)
        output_filename = os.path.join(
                dir_out, ('%s_%i%s' % (name, ind, ext)))
        #print(output_filename)
        cv2.imwrite(output_filename, crop)
