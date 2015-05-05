function [ captionMap ] = aggregateCaptions( captionListMap )
% Returns map from filenames to aggregated captions

filenames = captionListMap.keys;
captionMap = containers.Map();

for i = 1 : numel(filenames);
    filename = filenames{i};
    captionList = captionListMap(filename);
    % default
    caption = strjoin(captionList);
    captionMap(filename) = caption;
end

end