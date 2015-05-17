function [ output_args ] = featureCombination( ldaMatFile, NNMatFile )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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

end

