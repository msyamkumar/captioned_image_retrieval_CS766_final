%% Get list of image filenames
%structList = rdir('data/Flicker8k_Dataset/*00.jpg');
%imageFileList = {structList.name};

rng(0);

%% Get list of image filenames

% Get filenames for training set
fid = fopen('data/Flickr8k_text/Flickr_8k.trainImages.txt');
tmp = textscan(fid, '%s\n');
fTrain = tmp{1}(1:50);
fclose(fid);

% Get filenames for test set
fid = fopen('data/Flickr8k_text/Flickr_8k.testImages.txt');
tmp = textscan(fid, '%s\n');
fTest = tmp{1}(1:3);
fclose(fid);

imageBaseDir = 'data/Flicker8k_Dataset/';
dataBaseDir = 'data';

numTrain = numel(fTrain);
numTest = numel(fTest);
 
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


%% Extract image features of both training and test images

% Generate sift descriptors from both training and test images
imageFileList = [fTrain; fTest];
GenerateSiftDescriptors( imageFileList, imageBaseDir, dataBaseDir, params, canSkip, pfig );

% Calculate dictionary only from training images. IMPORTANT!!
imageFileList = fTrain;
CalculateDictionary( imageFileList, imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig );

% Build histograms from both training and test images
imageFileList = [fTrain; fTest];
textonHists = BuildHistograms( imageFileList,imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig );


%% Build feature vector for training image captions

captionMap = loadCaptionMap();

% Build vocabulary so that we can build bag of words
fullVocab = unique(strsplit(strjoin(values(captionMap, [fTrain; fTest]'))));  % strjoin adds a space delimiter
fullVocabSize = numel(fullVocab);

% Build non-Boolean BoW for each caption
bagsOfWords = zeros(numTrain + numTest, fullVocabSize);
fprintf('Building %i bags of words... ', size(bagsOfWords, 1)); tic;
imageFileList = [fTrain; fTest];
for i = 1 : numTrain + numTest
    tokens = strsplit(captionMap(imageFileList{i}));
    bagsOfWords(i, :) = countmember(fullVocab, tokens);
end
toc;

% Inverse document frequency given only the training data
fullIDFs = log(numTrain ./ sum(bagsOfWords(1 : numTrain, :) > 0));

% Get TFIDF
fullTFIDFs = bagsOfWords;
for i = 1 : size(fullTFIDFs, 1)
    fullTFIDFs(i, :) = fullTFIDFs(i, :) .* fullIDFs;
end
                           
kurtosises = kurtosis(fullTFIDFs);
[~, sortInds] = sort(kurtosises, 'descend');  %# Sort the values in descending order

selection = sortInds(end - 200 + 1 : end);  % Select least skewed words
vocab = fullVocab(selection);
IDFs = fullIDFs(selection);
TFIDFs = fullTFIDFs(:, selection);


%% Concatenate image and caption feature vectors

xTrain = [textonHists(1:numTrain, :) TFIDFs(1:numTrain, :)];
xTest = [textonHists(end - numTest + 1:end, :) TFIDFs(end - numTest + 1:end, :)];

resultInds = knnsearch(xTrain, xTest);
%%
for i = 1 : numel(resultInds)
    fQuery = fTest{i};
    cQuery = captionMap(fQuery);
    imQuery = imread(fullfile(imageBaseDir, fQuery));
    
    fResult = fTrain{resultInds(i)};
    cResult = captionMap(fResult);
    imResult = imread(fullfile(imageBaseDir, fResult));
    
    figure;
    subplot(121);imshow(imQuery);title(['Query: ' cQuery]);
    subplot(122);imshow(imResult);title(['Result: ' cResult]);
end