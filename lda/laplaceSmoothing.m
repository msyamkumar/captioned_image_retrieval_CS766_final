function [ v ] = laplaceSmoothing( v, alpha )
% Laplace smoothing of normalized distribution specified in v using coefficient alpha

d = alpha * numel(v);

for i = 1:numel(v)
    v(i) = (v(i) + alpha)/(1 + d);
end

end