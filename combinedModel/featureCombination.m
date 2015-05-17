function [ output_args ] = featureCombination( ldaMatFile, NNMatFile )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%%Calculate kNN

%LDA feature vector
load(ldaMatFile);
%DeepNet feature vector
load(NNMatFile);

%Taking transpose of DeepNet output to match format
feats = transpose(feats);

trainSize = size(X_train, 1);

%Assigning the training and testing feature set
ldaTrain = X_train;
ldaTest = X_test;
nnTrain = feats(1:trainSize, :);
nnTest = feats(trainSize + 1:end, :);

ldaVariance = var(ldaTrain(:));
nnVariance = var(nnTrain(:));

ldaTrain = ldaTrain./ldaVariance;
nnTrain = nnTrain./nnVariance;

combinedTrain = [ldaTrain nnTrain];

ldaTest = ldaTest./ldaVariance;
nnTest = nnTest./ldaVariance;

combinedTest = [ldaTest nnTest];

K = 3;
fprintf('Running KNN where K = %i... ', K);tic;
inds = knnsearch(combinedTrain, combinedTest, 'K', K);

%% Load filenames of train/test set

% Load image filenames of train/dev/test sets
filenames = {'../data/Flickr8k_text/Flickr_8k.trainImages.txt', ...
    '../data/Flickr8k_text/Flickr_8k.devImages.txt', ...
    '../data/Flickr8k_text/Flickr_8k.testImages.txt'};
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
train_filenames = train_filenames(ismember(train_filenames, im_filenames));
test_filenames = test_filenames(ismember(test_filenames, im_filenames));

%% Display results

if ~exist('do_display', 'var')  || do_display;

    for ii = 1:20

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

