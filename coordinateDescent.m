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


function log_gradm_g = computeLogGradMagEdge(data)
% replicate pixels at image boundaries to deal with boundary cases later on
Ilm = log(data.Im);
Ilm = [Ilm(1,:,:); Ilm; Ilm(end,:,:)];
Ilm = [Ilm(:,1,:) Ilm Ilm(:,end,:)];

% get the center image
center_Ilm = Ilm(2:end-1, 2:end-1, :);

% get the 4 images for the 4-connected neighborhood pixels
north_Ilm = Ilm(1:end-2, 2:end-1, :);
east_Ilm  = Ilm(2:end-1, 3:end,   :);
south_Ilm = Ilm(3:end,   2:end-1, :);
west_Ilm  = Ilm(2:end-1, 1:end-2, :);

log_grad_mag = zeros(size(data.Im,1), size(data.Im,2), 4);

log_grad_mag(:,:,1) = (center_Ilm - north_Ilm).^2;
log_grad_mag(:,:,2) = (center_Ilm - east_Ilm).^2;
log_grad_mag(:,:,3) = (center_Ilm - south_Ilm).^2;
log_grad_mag(:,:,4) = (center_Ilm - west_Ilm).^2;

log_gradm_g = data.g .* log_grad_mag;
end
