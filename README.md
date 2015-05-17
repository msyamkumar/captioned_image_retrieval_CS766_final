# Captioned image retrieval

We explore the task of retrieving similar captioned images from a dataset, given a previously unseen captioned image.

Note: the source code in `SpatialPyramid` has some bugs fixed. It is not exactly the same as the original source code from UIUC.

## To run baseline

1. Add `SpatialPyramid` to path
2. Unzip the Flickr 8k dataset to a `data` subdirectory
3. Run `close all; clear all; baseline;`

## To run crawling

1. Add the required search tags into `searchTags` array in line 13 of `crawler/gallerySearch.py`
2. Execute `python crawler/gallerySearch.py` 

Note: The crawled Imgur dataset (DataM) consists of 32K images and ~110K captions and is sized at ~16 gb. It can be provided on request.

## To run LDA
See readme in lda/

## To run CNN
See readme in caffenet/

## DataM dataset
The dataset and associated captions can be found at: http://pages.cs.wisc.edu/~ms/CS766-ComputerVision/captioned-image-retrieval/
