%% Build captions-only model of baseline


%% Get captions from each image

numCaptions = 10000;
captionMap = loadCaptionMap();
numImages = numel(captionMap.keys);
imageList = captionMap.keys;

% Change all captions to uppercase
for i = 1 : numImages
    captionMap(imageList{i}) = upper(captionMap(imageList{i}));
end

concatCaptions = captionMap.values;

% Build vocabulary so that we can build bag of words
fullVocab = unique(strsplit(strjoin(concatCaptions)));  % strjoin adds a space delimiter
fullVocabSize = numel(fullVocab);

% Build non-Boolean BoW for each caption
fprintf('Building %i bags of words... ', numImages); tic;
bagsOfWords = zeros(numImages, fullVocabSize);
for i = 1 : numImages
    tokens = strsplit(captionMap(imageList{i}));
    bagsOfWords(i, :) = countmember(fullVocab, tokens);
end
toc;

%% Analyze skewness of words

kurtosises = kurtosis(bagsOfWords);
[~, sortInds] = sort(kurtosises, 'descend');  %# Sort the values in
                                                  %#   descending order

numRanks = 5;  % Top N/ bottom N words
                                             
maxInds = sortInds(1:numRanks); 
minInds = sortInds(end - numRanks + 1: end);
fprintf('Top most skewed words in decreasing skewness\n');
disp(fullVocab(maxInds)');
fprintf('Least skewed words in increasing skewness\n');
disp(fullVocab(fliplr(minInds))');

%% Analyze document frequency of words

docFrequencies = sum(bagsOfWords > 0);

[~, sortInds] = sort(docFrequencies, 'descend');  %# Sort the values in
                                                  %#   descending order
numRanks = 5;  % Top N/ bottom N words
                                             
maxInds = sortInds(1:numRanks); 
minInds = sortInds(end - numRanks + 1: end);
midInds = sortInds(floor(fullVocabSize / 2 - numRanks / 2) : floor(fullVocabSize / 2 - numRanks / 2) + numRanks - 1);
fprintf('Words with highest doc frequency\n');
disp(fullVocab(maxInds)');
fprintf('Words with lowest doc frequency\n');
disp(fullVocab(fliplr(minInds))');
fprintf('Words with middle doc frequency\n');
disp(fullVocab(fliplr(midInds))');


%% Analyze tdidfs of words

tfidfs = bagsOfWords;
for i = 1 : numImages
    tfidfs(i, :) = tfidfs(i, :) ./ docFrequencies;
end
                           
kurtosises = kurtosis(tfidfs);
[~, sortInds] = sort(kurtosises, 'descend');  %# Sort the values in descending order

numRanks = 5;  % Top N/ bottom N words
                                             
maxInds = sortInds(1:numRanks); 
minInds = sortInds(end - numRanks + 1: end);
fprintf('Top most skewed words in decreasing skewness\n');
disp(fullVocab(maxInds)');
fprintf('Least skewed words in increasing skewness\n');
disp(fullVocab(fliplr(minInds))');
%%