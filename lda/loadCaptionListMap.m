function [ captionListMap ] = loadCaptionListMap( params )
% Returns a hashtable that maps image filename to its list of captions
% Assumes Flickr8 convention where lines are of format
% "<filename>#<0, 1, 2, 3 or 4> <caption>"
% Changes all captions to uppercase
%

% Load lines in file
filename = params.dataFile;
fid = fopen(filename);
lines = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
lines = lines{1};

numLines = numel(lines);
captionListMap = containers.Map();
pattern = '^(\S+)#(\d+)\t(.*)';

for i = 1 : numLines
    % Line is of the form "<filename>#<0, 1, 2, 3 or 4> <caption>"
    line = (lines{i});
    tokens = regexp(line, pattern, 'tokens');
    tokensList = tokens{1};
    filename = tokensList{1};
    captionNumber = tokensList{2};
    caption = upper(tokensList{3});

    captionList = cell(1,1);
    if isKey(captionListMap, filename)
        captionList = captionListMap(filename);
        captionList{end+1} = caption;
    else
        captionList{1} = caption;
        captionListMap(filename) = captionList;
    end
    captionListMap(filename) = captionList;
end