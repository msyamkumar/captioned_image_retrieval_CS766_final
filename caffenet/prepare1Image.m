function im_prepared = prepare1Image(im)
%% Process a M x N x 3 image for Caffenet
% Returns a center crop of a resized image
% Image is transposed because CaffeNet wants width to be first dimension
% Returns a CROPPED_DIM x CROPPED_DIM x 3 matrix

% ------------------------------------------------------------------------
IMAGE_DIM = 256;
CROPPED_DIM = 227;

d = load('ilsvrc_2012_mean');
IMAGE_MEAN = d.image_mean;
IMAGE_MEAN = imresize(IMAGE_MEAN, [CROPPED_DIM CROPPED_DIM], 'bilinear');

% resize to fixed input size
im = single(im);
im = imresize(im, [CROPPED_DIM CROPPED_DIM], 'bilinear');
% permute from RGB to BGR (IMAGE_MEAN is already BGR)
im = im(:,:,[3 2 1]) - IMAGE_MEAN;
% im = im(:,:,size(im, 3):-1:1) - IMAGE_MEAN;

im_prepared = permute(im, [2 1 3]);
% oversample (4 corners, center, and their x-axis flips)
% indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
% center = floor(indices(2) / 2)+1;
% im_center = ...
%     permute(im(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:), ...
%         [2 1 3]);