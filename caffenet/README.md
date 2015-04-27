#Run pre-trained deep network on Flickr8k dataset

Steps

1. Install Caffe with MATLAB support [[link](http://caffe.berkeleyvision.org/installation.html)]
2. Download pre-trained CaffeNet model [[link](http://caffe.berkeleyvision.org/model_zoo.html)]
2. Download synset: `./data/ilsvrc12/get_ilsvrc_aux.sh`
2. Add Caffe to MATLAB path, e.g. `addpath(genpath('~/builds/caffe'))`
2. Run `clear all; caffenetOnFlickr;` on MATLAB terminal
