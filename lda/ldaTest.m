function [ ] = ldaTest(captionMapTrain, captionMapTest, testFiles, WO, wordMap, WP, DP, params )
% Use LDA model to compute similar captions
%
% captionMapTest: map of image names to captions
% wordMap: map of words to their index in vocabulary
% WP: estimated words x topics counts matrix
% DP: estimated documents x topics counts matrix

alpha = params.laplaceSmoothingCoefficient;
outputFileID = fopen(params.outputFile, 'w');

testSize = numel(captionMapTest.keys);
trainImages = captionMapTrain.keys;

% training image feature vectors
[D, T] = size(DP);
WPdist = WP ./ repmat(sum(WP,2), 1, size(WP,2));
X_train = full(DP ./ repmat(sum(DP,2), 1, size(DP,2)));
for i = 1:D
    X_train(i,:) = laplaceSmoothing(X_train(i,:), alpha);
end
X_test = zeros(testSize, T);

% compute most likely captions and words for each topic
topicCaptions = zeros(3,T);
for i = 1:T
    [~,idx] = sort(X_train(:,i), 'descend');
    topicCaptions(:,i) = idx(1:3);
end
topicWords = zeros(3,T);
for i = 1:T
    [~,idx] = sort(WP(:,i), 'descend');
    topicWords(:,i) = idx(1:3);
end

num_figs = 10;
sim_figs = zeros(num_figs, 1);
topic_figs = zeros(num_figs, 1);

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
        dp2 = X_train(j,:);
        KL1 = sum( dist .* log2( dist ./ dp2 ));
        KL2 = sum( dp2 .* log2( dp2 ./ dist ));
        distances(i,j) = (KL1 + KL2)/2;
    end
    % compute nearest neighbors of document i
    [~,idx] = sort(distances(i,:));
    nearestNeighbors = trainImages(idx(1:params.K));
    fprintf('\n----> Query caption: %s\n\n', document);
    
    if strcmp(params.mode, 'TOPIC_SIMILARITY')
        % Identify most likely topics in image
        [prob, topics] = sort(dist, 'descend');
        fprintf('----> Most likely topics for query caption: %d %d %d\n', ...
            topics(1), topics(2), topics(3));
        if (params.toPlot)
            topic_figs(mod(i-1, num_figs) + 1) = figure;
            [X,mapX] = imread(fullfile(params.imageDir, testImage));
            subplot(4,3,2), imshow(X,mapX);
            title(sprintf('\\fontsize{18}Topic-wise similar images in each column: (a) topic %d (b) topic %d (c) topic %d', ...
                topics(1), topics(2), topics(3)));
        end
        for j = 1:3
            ntn = trainImages(topicCaptions(:,topics(j)));
            words = WO(topicWords(:,topics(j)));
            if (params.toPlot && 0)
                
            end
            fprintf('----> Most likely words for topic %d: %s %s %s\n', ...
                topics(j), words{1}, words{2}, words{3});
            if (params.toPlot)
                for k = 1:3
                    [X,mapX] = imread(fullfile(params.imageDir, ntn{k}));
                    subplot(4,3,j+3*k), imshow(X,mapX);
                end
            end
        end
    end

    % write to output file
    fprintf(outputFileID, '%s', testImage);
    for j = 1:numel(nearestNeighbors)
        fprintf(outputFileID, ' %s', nearestNeighbors{j});
    end
    fprintf(outputFileID, '\n');

    % plot images
    if (params.toPlot)
        sim_figs(mod(i-1, num_figs) + 1) = figure;
        [X,mapX] = imread(fullfile(params.imageDir, testImage));
        subplot(3,3,1), imshow(X,mapX);
        fprintf('----> Nearest neighbors for query caption:\n');
        for j = 1:numel(nearestNeighbors)
            [X,mapX] = imread(fullfile(params.imageDir, nearestNeighbors{j}));
            subplot(3,3,j+3), imshow(X,mapX);
            fprintf('%s\n', captionMapTrain(nearestNeighbors{j}));
        end
        if mod(i, num_figs) == 0
            pause;
            for j = 1 : num_figs
                close(sim_figs(j));
                if strcmp(params.mode, 'TOPIC_SIMILARITY')
                    close(topic_figs(j));
                end
            end
        end
    end
end
fclose(outputFileID);
save(params.outputFeaturesFile, 'X_train', 'X_test');

end

