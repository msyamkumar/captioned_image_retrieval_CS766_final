% Run LDA on image captions

clear all;
close all;
clc;

addpath('../topictoolbox');

params.dataDir = '../data';
params.stopWordsFile = fullfile(params.dataDir, 'stopwordlist.txt');

params.imageDir = fullfile(params.dataDir, 'Flicker8k_Dataset');
params.captionsFile = fullfile(params.dataDir, 'captionMap.mat');
params.modelFile = fullfile(params.dataDir, 'ldasingle_imagecaptions.mat');
params.topicsFile = fullfile(params.dataDir, 'topics.txt');
params.dataFile = fullfile(params.dataDir, ...
    fullfile('Flickr8k_text', 'Flickr8k.lemma.token.txt'));
params.trainFile = fullfile(params.dataDir, ...
    fullfile('Flickr8k_text', 'Flickr_8k.trainImages.txt'));
params.testFile = fullfile(params.dataDir, ...
    fullfile('Flickr8k_text', 'Flickr_8k.testImages.txt'));
params.outputFile = fullfile(params.dataDir, 'lda_output.txt');
params.outputFeaturesFile = fullfile(params.dataDir, 'lda_output_features.mat');

% params.imageDir = fullfile(params.dataDir, 'imgur_crawled');
% params.captionsFile = fullfile(params.dataDir, 'captionMap2.mat');
% params.modelFile = fullfile(params.dataDir, 'ldasingle_imagecaptions2.mat');
% params.topicsFile = fullfile(params.dataDir, 'topics2.txt');
% params.dataFile = fullfile(params.dataDir, ...
%     fullfile('imgur_crawled', 'captions.txt'));
% params.trainFile = fullfile(params.dataDir, ...
%     fullfile('imgur_crawled', 'trainingData.txt'));
% params.testFile = fullfile(params.dataDir, ...
%     fullfile('imgur_crawled', 'testingData3.txt'));
% params.outputFile = fullfile(params.dataDir, 'lda_output2.txt');
% params.outputFeaturesFile = fullfile(params.dataDir, 'lda_output_features2.mat');

% number of topics
params.T = 50;
params.ALPHA = 50/params.T;
% number of nearest neighbors to return
params.K = 6;
% Laplace smoothing coefficient for computing KL divergence
params.laplaceSmoothingCoefficient = 0.0001;
% maximum number of captions to be used
params.maxCaptions = 10;

% plot images
params.toPlot = 1;

% skip files if already generated
params.toSkip = 0;

%% Retrieve image captions into map captionsMap
disp('Loading image captions...');
if exist(params.captionsFile, 'file') && params.toSkip
    load(params.captionsFile);
else
    captionListMap = loadCaptionListMap(params);
    numImages = numel(captionListMap.keys);
    imageList = captionListMap.keys;

    % load image captions
    captionListMap = loadCaptionListMap(params);

    % aggregate captions
    captionMap = aggregateCaptions(captionListMap);

    % cache captions file
    save(params.captionsFile, 'captionMap', 'numImages', 'imageList');
end
clear numImages imageList;
disp('Done.');

%% Split into training/test data
disp('Splitting into training/test data...');
[trainFiles, captionMapTrain, testFiles, captionMapTest] = ...
    splitData(captionMap, params.trainFile, params.testFile);
disp('Done.');

%% Build bag-of-words and vocabulary
disp('Building bag-of-words and vocabulary...');
[WO, wordMap, WS, DS] = ldaBuildBagOfWords(captionMapTrain, params);
params.BETA = 200/numel(WO);
disp('Done.');

%% Build model
disp('Building LDA model...');
[WP, DP, Z] = ldaBuildModel(WO, WS, DS, params);
disp('Done.');

%% Test model
disp('Testing LDA model...');
tic;
ldaTest(captionMapTrain, captionMapTest, testFiles, wordMap, WP, DP, params);
toc;
disp('Done.');