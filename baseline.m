%% Get list of image filenames
%structList = rdir('data/Flicker8k_Dataset/*00.jpg');
%imageFileList = {structList.name};


%%
fid = fopen('data/Flickr8k_text/Flickr_8k.trainImages.txt');
tmp = textscan(fid, '%s\n');
imageFileList = tmp{1}(1:10);
fclose(fid);

imageBaseDir = 'data/Flicker8k_Dataset/';
dataBaseDir = 'data';

numImages = numel(imageFileList);

%% Define parameters of feature extraction

params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImages = 50;
params.pyramidLevels = 3;
params.oldSift = false;

canSkip = 1;
pfig = figure;

% Default suffix where SIFT features are stored. One mat file is generated per image.
featureSuffix = '_sift.mat';

% Default dictionary created by CalculateDictionary. We need to delete this
% if we want to create a new dictionary.
dictFilename = sprintf('dictionary_%d.mat', params.dictionarySize);

% Default suffix of files created by BuildHistograms
textonSuffix = sprintf('_texton_ind_%d.mat',params.dictionarySize);
histSuffix = sprintf('_hist_%d.mat', params.dictionarySize);

% Default suffix of files created by CompilePyramid
pyramidSuffix = sprintf('_pyramid_%d_%d.mat', params.dictionarySize, params.pyramidLevels);


%% Extract features of both training and test images

xTrain = [];  % feature vectors for training set
xTest = [];  % feature vectors for test set

% Generate sift descriptors from both training and test images
GenerateSiftDescriptors( imageFileList, imageBaseDir, dataBaseDir, params, canSkip, pfig );

% Calculate dictionary only from training images. IMPORTANT!!
CalculateDictionary( imageFileList, imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig );

% Build histograms from both training and test images
H_all = BuildHistograms( imageFileList,imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig );
