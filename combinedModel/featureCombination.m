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




end

