function log_gradm_g = computeLogGradMagEdge(data)
% Computes the log image magnitude gradient (in direction of 4-connected 
% pixels where i is the center pixel and j is the neighboring pixel) only 
% at locations where there a reflectance edge. This is actually the latter 
% half of eq (5) in Gehler et al. NIPS 2011
%
% Inputs:
%   data.Im - magnitude of the input image
%   data.g - the stack of binary images in 4 directions telling between
%       which two neighboring pixels there is a reflectance edge
% 
% Outputs:
%   log_grad_mag - cell array giving log image magnitude gradient between 
%       center pixel and 4-connected pixel neighborhood. There are 4 cells
%       each containing a double matrix
%           log_grad_mag{1}: when j is the north pixel
%           log_grad_mag{2}: when j is the east pixel
%           log_grad_mag{3}: when j is the south pixel
%           log_grad_mag{4}: when j is the west pixel
% 
% Ahmad Humayun
% July 8, 2012

% compute the log of each pixel's magnitude (plus replicate pixels at 
% image boundaries to deal with boundary cases later on)
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

% log gradient in each of the 4 directions
log_grad_mag(:,:,1) = (center_Ilm - north_Ilm).^2;
log_grad_mag(:,:,2) = (center_Ilm - east_Ilm).^2;
log_grad_mag(:,:,3) = (center_Ilm - south_Ilm).^2;
log_grad_mag(:,:,4) = (center_Ilm - west_Ilm).^2;

% discard all log gradient values where there is not a reflectance edge
log_gradm_g = data.g .* log_grad_mag;

% convert the stack into a cell array
log_gradm_g = mat2cell(log_gradm_g, size(log_gradm_g,1), size(log_gradm_g,2), [1 1 1 1]);
end
