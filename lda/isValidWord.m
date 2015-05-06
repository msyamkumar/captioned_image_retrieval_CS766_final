function [ out ] = isValidWord( word )
% returns true for word containing no extraneous punctuation or numbers

out = ~isempty(regexp(word,'^([a-zA-Z]|-)+$', 'once'));
end