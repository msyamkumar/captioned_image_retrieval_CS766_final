% function [scores, maxlabel] = matcaffe_demo(im, use_gpu)

%% Apply CaffeNet to Flickr8k data
% 
% We want to feed Flicker8k data to a pre-trained model CaffeNet. The
% motivation is to get a lower-dimensional representation of arbitrary
% (including arbitrarily-sized) images.
% 
% We will remove the last soft-max layer of CaffeNet


% input
%   im       color image as uint8 HxWx3
%   use_gpu  1 to use the GPU, 0 to use the CPU
%
% output
%   scores   1000-dimensional ILSVRC score vector
%
% You may need to do the following before you start matlab:
%  $ export LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64:/usr/local/cuda-5.5/lib64
%  $ export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
% Or the equivalent based on where things are installed on your system
%
% Usage:
%  im = imread('../../examples/images/cat.jpg');
%  scores = matcaffe_demo(im, 1);
%  [score, class] = max(scores);
% Five things to be aware of:
%   caffe uses row-major order
%   matlab uses column-major order
%   caffe uses BGR color channel order
%   matlab uses RGB color channel order
%   images need to have the data mean subtracted

% Data coming in from matlab needs to be in the order 
%   [width, height, channels, images]
% where width is the fastest dimension.
% Here is the rough matlab for putting image data into the correct
% format:
%   % convert from uint8 to single
%   im = single(im);
%   % reshape to a fixed size (e.g., 227x227)
%   im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
%   % permute from RGB to BGR and subtract the data mean (already in BGR)
%   im = im(:,:,[3 2 1]) - data_mean;
%   % flip width and height to make width the fastest dimension
%   im = permute(im, [2 1 3]);

% If you have multiple images, cat them with cat(4, ...)

% The actual forward function. It takes in a cell array of 4-D arrays as
% input and outputs a cell array. 

% Get directory of current running function since input files are in there
% NOTE: this dir is different from pwd
[func_dir, ~, ~] = fileparts(mfilename('fullpath'));

% init caffe network (spews logging info)
model_def_file = fullfile(func_dir, 'deploy.prototxt');
model_file = fullfile(func_dir, 'bvlc_reference_caffenet.caffemodel');
if ~exist(model_def_file, 'file')
    error('Model definition file %s not found', model_def_file);
end
if ~exist(model_file, 'file')
    error('Model file %s not found', model_file);
end
caffe('init', model_def_file, model_file, 'test')
caffe('set_mode_cpu');
fprintf(['Initialized Caffe\n' ...
    'Model definition file:\n\t%s\nModel file:\n\t%s\n'], ...
    model_def_file, model_file);

%Get a couple of nice FILENAMES! Ooo yeah
tmp_struct = dir('data/Flicker8k_Dataset');
im_filenames = {tmp_struct.name};
im_filenames = im_filenames(3:5);

ims = cell(1, numel(im_filenames));
for i = 1 : numel(ims)
    im = imread(im_filenames{i});
    if size(im, 3) == 1
        im = repmat(im, [1 1 3]);
    end
    ims{i} = im;
end

% prepare oversampled input
% input_data is Height x Width x Channel x Num
tic;
crop_sets = cell(1, numel(ims));
for i = 1 : numel(ims)
    im = ims{i};
    curr_crops = prepare_image(im);
    crop_sets{i} = curr_crops;
end
toc;

crop_sets{1}(:, :, :, 6:10) = crop_sets{2}(:, :, :, 1:5);

%% do forward pass to get scores
% scores are now Width x Height x Channels x Num
tic;
for i = 1 : numel(crop_sets)
    crop_set = crop_sets(i);
    feat = caffe('forward', crop_set);
    feat = feat{1};
    feat = squeeze(feat);
    feat = mean(feat,2);
    
    feats{i} = feat;
end
fprintf('Forward pass = %f s\n', toc);

%%

labels = loadSynsets();
for i = 1 : numel(ims)

    [~, maxInd] = max(feats{i});
    label = labels{maxInd};
    
    figure('name', label);
    subplot(121);
    imshow(ims{i})
    subplot(122);
    plot(feats{i});
end