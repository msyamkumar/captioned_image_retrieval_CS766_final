%% Performs KNN search given a set of image filenames and their corresponding feature vector.

archive = 'centerCrops.mat';
if exist(archive, 'file')
    load(archive);
end

%% Load filenames of train/test set

% Load image filenames of train/dev/test sets
filenames = {'/data/Flickr8k_text/Flickr_8k.trainImages.txt', ...
    '/data/Flickr8k_text/Flickr_8k.devImages.txt', ...
    '/data/Flickr8k_text/Flickr_8k.testImages.txt'};
for i = 1 : numel(filenames)
    filename = filenames{i};
    fid = fopen(filename);
    if fid == -1; error('Error: %s cannot be opened', filename); end;
    tmp = textscan(fid, '%s\n');
    im_filename_sets{i} = tmp{1};
end

% Join train and dev sets together; test set is separate
train_filenames = [im_filename_sets{1}; im_filename_sets{2}];
test_filenames = im_filename_sets{end};

% Remove filenames that weren't featurized (that's <10 examples)
train_filenames = train_filenames(ismember(train_filenames, im_filenames));
test_filenames = test_filenames(ismember(test_filenames, im_filenames));

fprintf('%i training examples\n', numel(train_filenames));
fprintf('%i test examples\n', numel(test_filenames));

%% Create a hashmap that maps from a filename to the index of im_filenames
filename2ind = containers.Map;
for i = 1 : numel(im_filenames)
    filename2ind(im_filenames{i}) = i;
end

%% Split feature matrix into training and test sets

trainInds = cell2mat(filename2ind.values(train_filenames));
xTrain = feats(:, trainInds)';
testInds = cell2mat(filename2ind.values(test_filenames));
xTest = feats(:, testInds)';

%% Get KNN of each test instance

fprintf('Running KNN... ');tic;
inds = knnsearch(xTrain, xTest);
fprintf('Done in %f s\n', toc);

%% Display results

for ii = 300:320
    query_filename = test_filenames{ii};
    result_filename = train_filenames{inds(ii)};
    
    figure;
    subplot(121);
    title('Query');
    imshow(imread(query_filename));
    subplot(122);
    title('Result');
    imshow(imread(result_filename));
end

%% Save results

output_filename = fullfile(fileparts(mfilename('fullpath')), 'caffenet_results.txt');
fid = fopen(output_filename, 'w');
for ii = 1 : numel(test_filenames)
    
    query_filename = test_filenames{ii};
    result_filename = train_filenames{inds(ii)};
    
    fprintf(fid, '%s\t%s\n', query_filename, result_filename);
end
fclose(fid);