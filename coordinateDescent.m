function [s, R] = coordinateDescent(I, mask)
%COORDINATEDESCENT Summary of this function goes here
%   Detailed explanation goes here

settings.theta_g = 10;
settings.theta_c = 6;

% check if its a color image
assert(size(I,3) == 3, 'This algorithm only works on color images');

% convert to input image to double and mask to binary for consistency
data.I = im2double(I);
data.mask = logical(mask);

%%%%%%%%%%%%%% Compute constants for the algorithm %%%%%%%%%%%%%%
% compute magnitude (l2 norm) of each pixel -> ||I_i||
data.Im = sqrt(sum(data.I.^2, 3));

% compute reflectance direction -> \vec{R}_i
data.Rd = bsxfun(@times, data.I, 1./data.Im);

% find the reflectance edges btw pixel i and j (4-connected neighborhood)
data.g = computeReflectanceEdge(data, settings);

% compute log image gradient multiplied only at reflectance edges (used by
% gradient consistency - retinex term E_{ret})
data.log_gradm_g = computeLogGradMagEdge(data);
end

