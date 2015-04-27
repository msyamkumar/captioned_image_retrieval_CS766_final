function [ captionMapTrain, captionMapTest ] = splitData( captionMap )
% splits data into training and test caption maps

if ~exist('trainingFilename', 'var')
    trainFile = 'data/Flickr8k_text/Flickr_8k.trainImages.txt';
end
if ~exist('testFilename', 'var')
    testFile = 'data/Flickr8k_text/Flickr_8k.testImages.txt';
end

% Identify training/test images
captionMapTrain = containers.Map();
trainFileID = fopen(trainFile);
trainList = textscan(trainFileID, '%s');
for i = 1 : numel(trainList{1})
    word = char(trainList{1}(i));
    captionMapTrain(word) = captionMap(word);
end

captionMapTest = containers.Map();
testFileID = fopen(testFile);
testList = textscan(testFileID, '%s');
for i = 1 : numel(testList{1})
    word = char(testList{1}(i));
    captionMapTest(word) = captionMap(word);
end

end