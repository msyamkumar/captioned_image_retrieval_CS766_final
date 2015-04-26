% Build bag-of-words model and vocabulary from image captions

%% Get captions from each image
disp('Retrieving image captions...');
if ~exist('dataDir', 'var')
    dataDir = 'data';
end
if ~exist('stopWordsFile', 'var')
    stopWordsFile = fullfile(dataDir, 'stopwordlist.txt');
end

captionsFile = fullfile(dataDir, 'captionMap.mat');
if exist(captionsFile, 'file')
    load(captionsFile);
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

concatCaptions = captionMap.values;

% Build vocabulary so that we can build bag of words
disp('Building vocabulary...');
V = unique(strsplit(strjoin(concatCaptions)));  % strjoin adds a space delimiter
idx = zeros(numel(V),1);

% map from words to their index in vocabulary
wordMap = containers.Map();

% load list of stop words into map
stopWords = containers.Map();
if exist(stopWordsFile, 'file')
    stopWordsFileID = fopen(stopWordsFile);
    stopWordsList = textscan(stopWordsFileID, '%s');
    for i = 1 : numel(stopWordsList{1})
        word = upper(char(stopWordsList{1}(i)));
        stopWords(word) = 1;
    end
    fclose(stopWordsFileID);
end

% clean up vocabulary of punctuation, numbers and stop words
k = 1;
for i = 1 : numel(V)
    word = char(V(i));
    if isValidWord(word) && ~isKey(stopWords, word)
        idx(i) = 1;
        wordMap(word) = k;
        k = k + 1;
    end
end

idx = logical(idx);
V = V(idx);

vocabSize = numel(V);

% Build token, document index vectors
disp('Building token and document index vectors...');
clear WS DS;
k = 1;
for i = 1 : numImages
    tokens = strsplit(captionMap(imageList{i}));
    for j = 1 : numel(tokens)
        word = char(tokens(j));
        if isKey(wordMap, word)
            WS(k) = wordMap(word);
            DS(k) = i;
            k = k + 1;
        end
    end
end

WO = V';
save(fullfile(dataDir, 'words_imagecaptions.mat'), 'WO');

WS = WS';
DS = DS';
save(fullfile(dataDir, 'bagofwords_imagecaptions.mat'), 'WS', 'DS');
