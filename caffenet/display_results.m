function display_results()

filenames = {'caffenet/finetune_iter_9000_results.txt', ...
    'caffenet/caffenet_results.txt'};
filenames = {'prefine_fullcrop.txt', 'postfine_fullcrop.txt'};
% filenames = {'finetune_iter_9000_results.txt', 'postfine_fullcrop.txt'};
map1 = getQuery2Result(filenames{1});
map2 = getQuery2Result(filenames{2});
[~, title1, ~] = fileparts(filenames{1});
[~, title2, ~] = fileparts(filenames{2});

filename = '/data/Flickr8k_text/Flickr_8k.testImages.txt';
fid = fopen(filename);
if fid == -1; error('Error: %s cannot be opened', filename); end;
queries = textscan(fid, '%s\n');
queries = queries{1};

imreadsquare = @(filename) padsquare(scale(imread(filename)));

% Read filenames into a matrix then we'll load these images and montage
% them
filename_cell = cell(30, 3);
for i = 1 : size(filename_cell, 1)
    query = (queries{i});
    result1 = (map1(query));
    result2 = (map2(query));
    
    filename_cell{i, 1} = query;
    filename_cell{i, 2} = result1;
    filename_cell{i, 3} = result2;
end

filename_cell = filename_cell';
numFilenames = size(filename_cell, 2);
% Sort results by whether the results changed after fine tuning, whether it
% didn't
change_inds = []; % Column inds of queries that changed
for i = 1 : size(filename_cell, 2)
    is_same = strcmp(filename_cell{2, i}, filename_cell{3, i});
    if ~is_same
        change_inds = [change_inds i];
    end
end
mask = zeros(1, numFilenames);
mask(change_inds) = 1;
mask = mask == 1;
filename_cell = [filename_cell(:, mask) filename_cell(:, ~mask)];

% Load images
image_cell = cell(size(filename_cell));
for i = 1 : numel(filename_cell)
    filename = filename_cell{i};
    im = imreadsquare(filename);
    image_cell{i} = im;
end

% Display images
minibatch_size = 5;
numMinibatch = ceil(size(image_cell, 2) / minibatch_size);
for bi = 1 : numMinibatch
    
    curr_image_cell = image_cell(:, (bi - 1) * minibatch_size + 1: bi * minibatch_size);
    im_montage = cell2mat(curr_image_cell);
    figure('name', sprintf('%i', bi));
    imshow(im_montage);
end


function im_out = scale(im_in)

max_dim = max(size(im_in));
scale = 200 / max_dim;
im_out = (imresize(im_in, scale));