% Run LDA on image captions

addpath('topictoolbox');

params.dataDir = 'data';
params.imageDir = fullfile(params.dataDir, 'Flicker8k_Dataset');
params.stopWordsFile = fullfile(params.dataDir, 'stopwordlist.txt');
params.captionsFile = fullfile(params.dataDir, 'captionMap.mat');
params.modelFile = fullfile(params.dataDir, 'ldasingle_imagecaptions.mat');
params.topicsFile = fullfile(params.dataDir, 'topics.txt');

% number of topics
params.T = 50;
params.ALPHA = 50/params.T;
% number of nearest neighbors to return
params.K = 6;
% Laplace smoothing coefficient for computing KL divergence
params.laplaceSmoothingCoefficient = 0.0001;

%% Retrieve image captions into map captionsMap
disp('Loading image captions...');
if exist(params.captionsFile, 'file')
    load(params.captionsFile);
else
    captionMap = loadCaptionMap();
    numImages = numel(captionMap.keys);
    imageList = captionMap.keys;

    % Change all captions to uppercase
    for i = 1 : numImages;
        captionMap(imageList{i}) = upper(captionMap(imageList{i}));
    end

    % cache captions file
    save(captionsFile, 'captionMap', 'numImages', 'imageList');
end
clear numImages imageList;
disp('Done.');

%% Split into training/test data
disp('Splitting into training/test data...');
[captionMapTrain, captionMapTest] = splitData(captionMap);
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
ldaTest(captionMapTrain, captionMapTest, wordMap, WP, DP, params);
disp('Done.');