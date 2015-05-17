function [ WO, wordMap, WS, DS ] = ldaBuildBagOfWords( captionMap, params )
% Builds bag-of-words model and vocabulary from image captions

if exist(params.bowFile, 'file') && params.toSkip
    load(params.bowFile);
    return;
end

stopWordsFile = params.stopWordsFile;
numImages = numel(captionMap.keys);
imageList = captionMap.keys;
concatCaptions = captionMap.values;

% Build vocabulary so that we can build bag of words
disp('Building vocabulary...');
% strjoin adds a space delimiter
V = unique(strsplit(strjoin(concatCaptions), params.delimiterRegex, ...
    'DelimiterType', 'RegularExpression', 'CollapseDelimiters', true));
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

% Gather tokens
tokensM = cell(numImages, 1);
for i = 1 : numImages
    tokensM{i} = strsplit(captionMap(imageList{i}), params.delimiterRegex, ...
        'DelimiterType', 'RegularExpression', 'CollapseDelimiters', true);
end

% % Build token, document index vectors
% disp('Building token and document index vectors...');
% clear WS DS;
% k = 1;
% for i = 1 : numImages
%     tokens = tokensM{i};
%     for j = 1 : numel(tokens)
%         word = char(tokens(j));
%         if isKey(wordMap, word)
%             WS(k) = wordMap(word);
%             DS(k) = i;
%             k = k + 1;
%         end
%     end
% end

% Build tf-idf matrices
disp('Building TF-IDF matrices...');
counts = zeros(numel(V), numImages);
for i = 1 : numImages
    tokens = tokensM{i};
    for j = 1 : numel(tokens)
        word = char(tokens(j));
        if isKey(wordMap, word)
            k = wordMap(word);
            counts(k,i) = counts(k,i) + 1;
        end
    end
end
TF = 0.5 + (0.5 .* counts) ./ repmat(max(counts),numel(V),1);
IDF = repmat(log(numImages ./ sum(logical(counts),2)), 1, numImages);
W = TF .* IDF;

% Build token, document index vectors
disp('Building token and document index vectors...');
clear WS DS;
k = 1;
for i = 1 : numImages
    tokens = unique(tokensM{i});
    % get token weights
    tokenWeights = zeros(numel(tokens), 1);
    for j = 1 : numel(tokens)
        word = char(tokens(j));
        if isKey(wordMap, word)
            idx = wordMap(word);
            tokenWeights(j) = W(idx,i);
        end
    end
    % round token weights to counts
    tokenWeights = round(tokenWeights);
    for j = 1 : numel(tokens)
        word = char(tokens(j));
        if isKey(wordMap, word);
            for c = 1 : tokenWeights(j)
                WS(k) = wordMap(word);
                DS(k) = i;
                k = k + 1;
            end
        end
    end
end

WO = V';
WS = WS';
DS = DS';

save(params.bowFile, 'WO', 'wordMap', 'WS', 'DS');