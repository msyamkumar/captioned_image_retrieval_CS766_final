function display_joint_model_results()

load('text_further_inds.mat', 'text_further_inds');
load('visual_further_inds.mat', 'visual_further_inds');
load('equal_inds.mat', 'equal_inds');

%% Load image filenames of train/dev/test sets
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

%% Create cell array of filenames

filename_cell = cell(numel(test_filenames), 4);
filename_cell(:, 1) = test_filenames;
filename_cell(:, 2) = train_filenames(equal_inds(:, 1));
filename_cell(:, 3) = train_filenames(visual_further_inds(:, 1));
filename_cell(:, 4) = train_filenames(text_further_inds(:, 1));

filename_cell = filename_cell(1:20, :);

imreadsquare = @(filename) padsquare(scale(imread(filename)));

% Load images
image_cell = cell(size(filename_cell));
for i = 1 : numel(filename_cell)
    filename = filename_cell{i};
    im = imreadsquare(filename);
    image_cell{i} = im;
end

% Display images
minibatch_size = 5;
numMinibatch = ceil(size(image_cell, 1) / minibatch_size);
for bi = 1 : numMinibatch
    
    curr_image_cell = image_cell((bi - 1) * minibatch_size + 1: bi * minibatch_size, :);
    im_montage = cell2mat(curr_image_cell);
    figure('name', sprintf('%i', bi));
    imshow(im_montage);
    
    if bi == 1
        imwrite(im_montage, 'joint_model.png');
    end
end

end

function im_out = scale(im_in)

max_dim = max(size(im_in));
scale = 300 / max_dim;
im_out = (imresize(im_in, scale));

end