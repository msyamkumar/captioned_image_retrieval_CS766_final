#Run pre-trained deep network on Flickr8k dataset

Steps

1. Install Caffe with MATLAB support [[link](http://caffe.berkeleyvision.org/installation.html)]
2. Download pre-trained CaffeNet model [[link](http://caffe.berkeleyvision.org/model_zoo.html)]
2. Download synset: `./data/ilsvrc12/get_ilsvrc_aux.sh`
2. Add Caffe to MATLAB path, e.g. `addpath(genpath('~/builds/caffe'))`
2. Run `clear all; caffenetOnFlickr;` on MATLAB terminal

Results

Results of the modified CaffeNet (with the top softmax layer removed) are given
in `caffenet_results.txt`. Each line is a query filename, from the test set,
followedy by the result filename, from either the train or dev set. We merged
the train/dev set of Flickr8k into one since there was no training in this
procedure.

There are 999 lines in the results file. One test instance is missing.
