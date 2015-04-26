function [ synsets ]= loadSynsets( filename )
%LOADSYNSETS Load synsets, a.k.a labels of ImageNet challenge
%   Returns a 1000x1 cell array of strings
%   
%   `filename` full or relative path to synset_words.txt
%   Lines are in the form:
%   <ID> <word1>, <word2>, ..., <wordN>

if nargin < 1
    filename = '/home/bjiashen/builds/caffe/data/ilsvrc12/synset_words.txt';
end

fid = fopen(filename);
synsets = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
synsets = synsets{1};

numLines = 1000;  % ImageNet has 1000 classes

if numLines ~= numel(synsets);
    error('Incorrect number of lines %i, should be %i', numel(synsets), numLines);
end;

% Lines are in the form:
% <ID> <word1>, <word2>, ..., <wordN>
for i = 1 : numLines    
    line = (synsets{i});
    
    % Remove ID
    space_inds = strfind(line, ' ');
    synsets{i} = line(space_inds(1) + 1 : end);
end
    