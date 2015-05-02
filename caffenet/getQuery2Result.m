function [ query2result ] = getQuery2Result( filename )
%GETQUERY2RESULT Returns a map from query to result
%   Each line in file should be
%   <query><space><result><newline>

fid = fopen(filename);
if fid == -1; error('Error: %s cannot be opened', filename); end;
tmp = textscan(fid, '%s %s\n');
query2result = containers.Map(tmp{1}, tmp{2});

end

