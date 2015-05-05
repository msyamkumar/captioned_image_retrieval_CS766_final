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

% model_def_file = fullfile(func_dir, 'finetune_deploy.prototxt');
% model_file = fullfile(func_dir, 'finetune_iter_9000.caffemodel');

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

%Get a couple of nice FILENAMES! of images. Ooo yeah
im_filenames = {};
filenames = {'/data/Flickr8k_text/Flickr_8k.trainImages.txt', ...
    '/data/Flickr8k_text/Flickr_8k.devImages.txt', ...
    '/data/Flickr8k_text/Flickr_8k.testImages.txt'};
for i = [1 3]
    filename = filenames{i};
    fid = fopen(filename);
    if fid == -1; error('Error: %s cannot be opened', filename); end;
    tmp = textscan(fid, '%s\n');
    im_filenames = [im_filenames; tmp{1}];
end

fprintf('Running prediction on %i images.\n', numel(im_filenames));
% tmp_struct = dir('data/Flicker8k_Dataset');
% im_filenames = {tmp_struct.name};lear a
% im_filenames = im_filenames(3:end);  % Remove . and ..

% make dataset multiple of 10 since network takes ten image at a time
im_filenames = im_filenames(1:end - mod(numel(im_filenames), 10));

% im_filenames = im_filenames(1:30);

% Feature vectors 1000 x M size, one column for one image filename
feats = [];

%% Compute features by batches of ten images
tic;
minibatch_size = 100;
for ii = 1 : numel(im_filenames)
    im = imread(im_filenames{ii});
        
    % Crop current image and place into the batch of ten
    % curr_crop is Height x Width x Channel
%     IMAGE_DIM = 227;
%     curr_crop = imresize(single(im), [IMAGE_DIM IMAGE_DIM], 'bilinear');
    curr_crop = prepare1Image(im);

    [h, w, c] = size(curr_crop);
    if mod(ii - 1, minibatch_size) == 0
        minibatch = zeros(h, w, c, minibatch_size, 'like', curr_crop);
    end
    minibatch(:, :, :, mod(ii - 1, minibatch_size) + 1) = curr_crop;

    % do forward pass to get features in batches of ten
    % scores are now Width x Height x Channels x Num
    if mod(ii - 1, minibatch_size) == minibatch_size - 1
        minibatch_feats = caffe('forward', {minibatch});
        minibatch_feats = squeeze(minibatch_feats{1});
        [numFeat, ~] = size(minibatch_feats);
        
        % Initialize feats
        if ii == 1
            feats = zeros(numFeat, numel(im_filenames), 'like', minibatch_feats);
        end
        
        % Slot this minibatch of features into the full batch
        feats(:, ii - minibatch_size + 1 : ii) = minibatch_feats;
    end
    
    if mod(ii, 100) == 0
        fprintf('Computed features for %i out of %i images\n', ii, numel(im_filenames));
    end
end
fprintf('Forward pass = %f s\n', toc);

%%

if false
    labels = loadSynsets();
    for ii = 1 : numel(im_filenames)

        feat = feats(:, ii);
        [~, maxInd] = max(feat);
        label = labels{maxInd};

        figure('name', label);
        subplot(121);
        imshow(imread(im_filenames{ii}));
        subplot(122);
        plot(feat);
    end
end
