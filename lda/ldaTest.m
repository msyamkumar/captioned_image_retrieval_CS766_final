function [ ] = ldaTest(captionMapTrain, captionMapTest, testFiles, wordMap, WP, DP, params )
% Use LDA model to compute similar captions
%
% captionMapTest: map of image names to captions
% wordMap: map of words to their index in vocabulary
% WP: estimated words x topics counts matrix
% DP: estimated documents x topics counts matrix
% Z: vector of topics estimated for each word in training data

alpha = params.laplaceSmoothingCoefficient;
outputFileID = fopen(params.outputFile, 'w');

testSize = numel(captionMapTest.keys);
trainImages = captionMapTrain.keys;

% training image feature vectors
[D, T] = size(DP);
WPdist = WP ./ repmat(sum(WP,2), 1, size(WP,2));
DPdist = full(DP ./ repmat(sum(DP,2), 1, size(DP,2)));
for i = 1:D
    DPdist(i,:) = laplaceSmoothing(DPdist(i,:), alpha);
end
X_train = DPdist;
X_test = zeros(testSize, T);

distances = zeros(testSize, D);
for i = 1 : testSize
    testImage = testFiles{i};
    document = captionMapTest(testImage);
    % estimate distribution over topics for this document
    dist = zeros(1, T);
    words = strsplit(document);
    k = 0;
    for j = 1 : numel(words)
        word = char(words(j));
        if isKey(wordMap, word)
            idx = wordMap(word);
            dist = dist + WPdist(idx,:);
            k = k + 1;
        end
    end
    dist = dist/k;
    dist = laplaceSmoothing(dist, alpha);
    X_test(i,:) = dist;

    % compute KL-divergence of distribution with the distributions over 
    % topics for all training documents
    for j = 1:D
        dp2 = DPdist(j,:);
        KL1 = sum( dist .* log2( dist ./ dp2 ));
        KL2 = sum( dp2 .* log2( dp2 ./ dist ));
        distances(i,j) = (KL1 + KL2)/2;
    end
    % compute nearest neighbors of document i
    [~,idx] = sort(distances(i,:));
    nearestNeighbors = trainImages(idx(1:params.K));

    % write to output file
    fprintf(outputFileID, '%s', testImage);
    for j = 1:numel(nearestNeighbors)
        fprintf(outputFileID, ' %s', nearestNeighbors{j});
    end
    fprintf(outputFileID, '\n');

    % plot images
    if (params.toPlot)
        fig1 = figure;
        [X,mapX] = imread(fullfile(params.imageDir, testImage));
        subplot(3,3,1), imshow(X,mapX);
        fprintf('\n----> Nearest neighbors for %s:\n\n', document);
        for j = 1:numel(nearestNeighbors)
            [X,mapX] = imread(fullfile(params.imageDir, nearestNeighbors{j}));
            subplot(3,3,j+3), imshow(X,mapX);
            fprintf('%s\n', captionMapTrain(nearestNeighbors{j}));
        end
        pause;
        close(fig1);
    end
end
fclose(outputFileID);
save(params.outputFeaturesFile, 'X_train', 'X_test');

end

