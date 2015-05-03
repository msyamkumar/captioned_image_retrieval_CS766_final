
filenames = {'caffenet/finetune_iter_9000_results.txt', ...
    'caffenet/caffenet_results.txt'};
filenames = {'prefine_fullcrop.txt', 'postfine_fullcrop.txt'};
map1 = getQuery2Result(filenames{1});
map2 = getQuery2Result(filenames{2});
[~, title1, ~] = fileparts(filenames{1});
[~, title2, ~] = fileparts(filenames{2});

filename = '/data/Flickr8k_text/Flickr_8k.testImages.txt';
fid = fopen(filename);
if fid == -1; error('Error: %s cannot be opened', filename); end;
queries = textscan(fid, '%s\n');
queries = queries{1};

for i = 1 : 30
    query = queries{i};
    result1 = map1(query);
    result2 = map2(query);
    
    figure;
    subplot(131);
    imshow(imread(query));
    title('Query');
    subplot(132);
    imshow(imread(result1));
    title(title1);
    subplot(133);
    imshow(imread(result2));
    title(title2);
end
