function [ captionMap ] = loadCaptionMap( N, filename )
%LOADCAPTIONMAP Returns a hashtable that maps image filename to its first caption
%     Assumes Flickr8 convention where lines are of format
%     "<filename>#<0, 1, 2, 3 or 4> <caption>"
%     Changes all captions to uppercase
%
%     `N` function returns captions of first N filenames (optional; default: loads all)
%     `filename` filename with caption data

if ~exist('filename', 'var')
    filename = 'data/Flickr8k_text/Flickr8k.lemma.token.txt';
end

% Load lines in file
fid = fopen(filename);
lines = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
lines = lines{1};

% Optionally subsample lines
if exist('N', 'var')
    if numel(lines) < N * 5
        error('Only have %i lines (i.e., %i filenames) but user requested %i filenames', ...
            numel(lines), numel(lines) / 5, N);
    end
    lines = lines(1 : N * 5);
end

numLines = numel(lines);
captionMap = containers.Map();

for i = 1 : numLines
    
    % Skip everything exception first caption of every line
    if (mod(i - 1, 5) ~= 0); continue; end;
    
    % Line is of the form "<filename>#<0, 1, 2, 3 or 4> <caption>"
    line = (lines{i});
    filename = subsref(strsplit(line, '#'), struct('type','{}','subs',{{1}}));
    caption = subsref(strsplit(line, {'\t'}), struct('type','{}','subs',{{2}}));
    %captionInd = subsref(strsplit(line, {'\t', '#'}), struct('type','{}','subs',{{2}}));
    
    captionMap(filename) = upper(caption);
end