function [ trainFiles, captionMapTrain, testFiles, captionMapTest ] = splitData( captionMap, trainFile, testFile )
% splits data into training and test caption maps

% Identify training/test images
captionMapTrain = containers.Map();
trainFileID = fopen(trainFile);
trainList = textscan(trainFileID, '%s');
trainSize = numel(trainList{1});
trainFiles = cell(trainSize,1);
for i = 1 : trainSize
    word = char(trainList{1}(i));
    trainFiles{i} = word;
    captionMapTrain(word) = captionMap(word);
end

captionMapTest = containers.Map();
testFileID = fopen(testFile);
testList = textscan(testFileID, '%s');
testSize = numel(testList{1});
testFiles = cell(testSize,1);
for i = 1 : testSize
    word = char(testList{1}(i));
    testFiles{i} = word;
    captionMapTest(word) = captionMap(word);
end

end