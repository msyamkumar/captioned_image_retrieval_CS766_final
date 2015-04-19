%% Build captions-only model of baseline


%% Get captions from each image

fid = fopen('data/Flickr8k_text/Flickr8k.lemma.token.txt');
concatCaptions = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
concatCaptions = concatCaptions{1}(1:10000);
numLines = numel(concatCaptions);
for i = 1 : numLines
    line = upper(concatCaptions{i});
    tokens = strsplit(line, '\t');
    concatCaptions{i} = tokens{end};
end

% Build vocabulary so that we can build bag of words
vocab = unique(strsplit(strjoin(concatCaptions')));  % strjoin adds a space delimiter
vocabSize = numel(vocab);

% Build non-Boolean BoW for each caption
fprintf('Building %i bags of words... ', numLines); tic;
bagsOfWords = zeros(numLines, vocabSize);
for i = 1 : numLines
    tokens = strsplit(concatCaptions{i});
    bagsOfWords(i, :) = countmember(vocab, tokens);
end
toc;

%% Analyze skewness of words

kurtosises = kurtosis(bagsOfWords);
[~, sortInds] = sort(kurtosises, 'descend');  %# Sort the values in
                                                  %#   descending order
%%
numRanks = 5;  % Top N/ bottom N words
                                             
maxInds = sortInds(1:numRanks); 
minInds = sortInds(end - numRanks + 1: end);
fprintf('Top most skewed words in decreasing skewness\n');
disp(vocab(maxInds)');
fprintf('Least skewed words in increasing skewness\n');
disp(vocab(fliplr(minInds))');