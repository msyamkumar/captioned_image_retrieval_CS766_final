%% Performs KNN search given a set of image filenames and their corresponding feature vector.

if exist('archive', 'var') && exist(archive, 'file')
    load(archive);
end
expected_vars = {'im_filenames', 'feats'};
for i = 1 : numel(expected_vars)
    if ~exist(expected_vars{i}, 'var')
        error('Variable %s not found', expected_vars{i});
    end
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
train_filenames = [im_filename_sets{1}];%; im_filename_sets{2}];
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

K = 3;
fprintf('Running KNN where K = %i... ', K);tic;
inds = knnsearch(xTrain, xTest, 'K', K);
fprintf('Done in %f s\n', toc);

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
    

%% Save results

if exist('do_save', 'var') && do_save
    
    if ~exist('archive', 'var')
        error('Did not specify archive file. Cannot generate output filename');
    end

    [~, filename, ext] = fileparts(archive);
    output_filename = fullfile(fileparts(mfilename('fullpath')), [filename '2.txt']);
    fid = fopen(output_filename, 'w');
    for ii = 1 : numel(test_filenames)

        query_filename = test_filenames{ii};
        result_filename = train_filenames{inds(ii)};
        
        fmt = ['%s' repmat('\t%s', 1, K) '\n'];
        fprintf(fid, fmt, query_filename, train_filenames{inds(ii, :)});
    end
    fclose(fid);
end