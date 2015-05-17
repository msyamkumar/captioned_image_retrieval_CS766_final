function [ output_args ] = featureCombination( ldaMatFile, NNMatFile )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%% Load filenames of train/test set

% Load image filenames of train/dev/test sets
filenames = {'Flickr_8k.trainImages.txt', ...
    'Flickr_8k.devImages.txt', ...
    'Flickr_8k.testImages.txt'};
for i = 1 : numel(filenames)
    filename = filenames{i};
    fid = fopen(filename);
    if fid == -1; error('Error: %s cannot be opened', filename); end;
    tmp = textscan(fid, '%s\n');
    im_filename_sets{i} = tmp{1};
end

% Join train and dev sets together; test set is separate
train_filenames = [im_filename_sets{1}];%; im_filename_sets{2}];
test_filenames = im_filename_sets{end};

% Remove filenames that weren't featurized (that's <10 examples)
% train_filenames = train_filenames(ismember(train_filenames, im_filenames));
% test_filenames = test_filenames(ismember(test_filenames, im_filenames));

%% Load features
%%Calculate kNN
% ldaMatFile = 'data/lda/lda_output_features.mat';
% NNMatFile = 'data/caffenet/postfine_fullcrop.mat';

%DeepNet feature vector
load(NNMatFile, 'feats', 'im_filenames');
tmp_feats = feats'; %Make feats such that a row is a feature vector
tmp_filenames = im_filenames;
% Split features into the order of train and test images
filename_inds = containers.Map(tmp_filenames(:), 1:numel(tmp_filenames));
test_feats = tmp_feats(cell2mat(values(filename_inds, test_filenames)), :);
train_feats = tmp_feats(cell2mat(values(filename_inds, train_filenames)), :);
nnTest = test_feats;
nnTrain = train_feats;

%LDA feature vector
load(ldaMatFile, 'X', 'filenames');
tmp_feats = X;
tmp_filenames = filenames;
% Split features into the order of train_filenames, test_filenames
filename_inds = containers.Map(tmp_filenames(:), 1:numel(tmp_filenames));
test_feats = tmp_feats(cell2mat(values(filename_inds, test_filenames)), :);
train_feats = tmp_feats(cell2mat(values(filename_inds, train_filenames)), :);
ldaTest = test_feats;
ldaTrain = train_feats;
 
% trainSize = size(X_train, 1);
% 
% %Assigning the training and testing feature set
% ldaTrain = X_train;
% ldaTest = X_test;
% nnTrain = text_feats(1:trainSize, :);
% nnTest = text_feats(trainSize + 1:end, :);

if 0
    numTrain = 10;
    fprintf('Subsampling training images to %i for speed\n', numTrain);
    ldaTrain = ldaTrain(1:numTrain, :);
    nnTrain = nnTrain(1:numTrain, :);
end

%% At this point we should have ldaTrain, ldaTest, nnTrain, nnTest

ldaSTD = std(ldaTrain(:));
nnSTD = std(nnTrain(:));

% ldaTrain = ldaTrain./ldaVariance;

% Concatenate visual and textual features of training data
% Make visual features same variance as texture features but maintain
% probability distribution property of LDA.
nnTrain = nnTrain / nnSTD * ldaSTD;
combinedTrain = [ldaTrain nnTrain];
% combinedTrain = [ldaTrain];

% Concatenate visual and textual features of test data
% ldaTest = ldaTest./ldaVariance;
nnTest = nnTest / nnSTD * ldaSTD;
combinedTest = [ldaTest nnTest];
% combinedTest = [ldaTest];

% Run search
numDistribution = size(ldaTrain, 2);
K = 3;
text_weight = 1;
visual_weight = 1;
fprintf('Running KNN where K = %i, KL weight = %f, L2 weight = %f\n', K, text_weight, visual_weight); tic;
% dist = @(x1, x2) getKLL2Dist(x1, x2, numDistribution, text_weight, visual_weight);
% dist = @(x1, x2) kldiv(x1, x2);
dist = @(x1, x2) getWeightedL2Dist(x1, x2, numDistribution, text_weight, visual_weight);
inds = knnsearch(combinedTrain, combinedTest, 'K', K, 'Distance', dist);
% inds = knnsearch(combinedTrain, combinedTest, 'K', K);
fprintf('Done in %f s\n', toc);


%% Display results

if ~exist('do_display', 'var')  || do_display;

    for ii = 1:10

        query_filename = test_filenames{ii};

        figure;
        hold on;
        subplot(1, K + 1, 1);
        imshow(imread(query_filename));
        title('Query');
        
        for ki = 1 : K
            result_filename = train_filenames{inds(ii, ki)};
            subplot(1, K + 1, ki + 1);
            imshow(imread(result_filename));
            title(sprintf('Top #%i result', ki));
        end
    end
end

end

function dist = kldiv(x1, x2)
% Returns symmetric KL divergence of x1 and x2
% `x1` is 1 x n
% `x2` m x n
% `dist` m x 1
m = size(x2, 1);

if 1
    
    % Calculate div(x2, x1)
    P = x2;  % the tall matrix
    Q = x1;  % the row vector
    Q = Q ./sum(Q);
    P = P ./repmat(sum(P,2),[1 size(P,2)]);
    temp =  P.*log(P./repmat(Q,[size(P,1) 1]));
    temp(isnan(temp))=0;% resolving the case when P(i)==0
    dist = sum(temp,2);
    divX2X1 = dist;
    
    % Calculate div(x1, x2)
    P = x1;  % the row vector
    Q = x2;  % the tall matrix
    P = P ./sum(P);
    Q = Q ./repmat(sum(Q,2),[1 size(Q,2)]);
    P = repmat(P, [m 1]);
    temp =  P.*log(P./Q);
    temp(isnan(temp))=0;% resolving the case when P(i)==0
    dist = sum(temp,2);
    divX1X2 = dist;
    
    dist = (divX2X1 + divX1X2) / 2;

else
    
    % Inefficient implementation
    divX2X1 = KLDiv(x2, x1);
    divX1X2 = zeros(m, 1);
    for i = 1 : m
        divX1X2(i) = KLDiv(x1, x2(i, :));
    end

    dist = (divX2X1 + divX1X2) / 2;
end

end

function dist = L2norm(x1, x2)
% Returns L2 norm of x1 and x2
% `x1` is 1 x n
% `x2` m x n
% `dist` m x 1
m = size(x2, 1);
diff = repmat(x1, [m 1]) - x2;
dist = sqrt(sum(diff.^2, 2));
end


function dist = getWeightedL2Dist(x1, x2, numDistribution, textWeight, visualWeight)

text_dist = L2norm(x1(1:numDistribution), x2(:, 1:numDistribution));
visual_dist = L2norm(x1(numDistribution + 1:end), x2(:, numDistribution + 1:end));
dist = textWeight * text_dist + visualWeight * visual_dist;

end

function dist = getKLL2Dist(x1, x2, numDistribution, klWeight, l2Weight)
% Returns the sum of (L2 distance of first half) and (KL divergence of
% second half) of vector pairs
% `numDistribution` no. of features to be included in KL divergence
% calculation. We assume that the first numDistribution dimensions of a
% vector are for KL divergence and all features after that are for L2 norm.
% `x1` is 1 x n
% `x2` m x n
% `dist` m x 1

if nargin <=3
    klWeight = 1;
    l2Weight = 1;
end

kldist = kldiv(x1(1:numDistribution), x2(:, 1:numDistribution));
l2dist = L2norm(x1(numDistribution + 1:end), x2(:, numDistribution + 1:end));
dist = klWeight * kldist + l2Weight * l2dist;

end