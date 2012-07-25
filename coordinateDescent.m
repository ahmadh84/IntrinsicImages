function [s, R] = coordinateDescent(I, mask)
% Computes the intrinsic image separation of the reflectance and shading
% using algorithm 1 in Gehler et al. NIPS 2011. This is a coordinate 
% descent solution to eq (3) in the paper.
%
% Inputs:
%   I - input RGB image
%   mask - binary mask giving the location of the object
% 
% Outputs:
%   s - a shading matrix of the same width and height as I
%   R - the reflectance matrix with 3 channels, same size as I
% 
% Ahmad Humayun
% July 11, 2012

settings.theta_g = 0.75;        % threshold for intensity edge
settings.theta_c = 1;           % threshold for chromaticity edge
settings.C = 5;                 % number of basis color clusters

settings.w_s = 1e-5;            % the weight for spatial prior term
settings.w_r = 1e-5;            % the weight for gradient consistency term
settings.w_cl = 1;              % the weight for global sparse reflectance 
                                % prior

settings.diff_theta = 1e-5;     % terminate looping if the difference in 
                                % energy between iteration is less than this 
                                % value

settings.minimize_max_iter = 1e4;

% add libraries to the path
curr_dir = fileparts(which(mfilename));
addpath(genpath(fullfile(curr_dir, 'libs')));


% check if its a color image
assert(size(I,3) == 3, 'This algorithm only works on color images');

% convert to input image to double and mask to binary for consistency
data.I = im2double(I);
data.mask = logical(mask);

%%%%%%%%%%%%%% Compute constants for the algorithm %%%%%%%%%%%%%%
% compute magnitude (l1 norm) of each pixel -> ||I_i||_1
data.Im = sum(data.I, 3);

% compute reflectance direction -> \vec{R}_i
data.Rd = bsxfun(@times, data.I, 1./data.Im);

data.nghb_masks = createNeighborhoodMasks(data.mask);

% find the reflectance edges btw pixel i and j (4-connected neighborhood)
data.g = computeReflectanceEdge(data, settings);

% compute log image gradient multiplied only at reflectance edges (used by
% gradient consistency - retinex term E_{ret})
data.log_gradm_g = computeLogGradMagEdge(data);

% Create discrete Laplacian operator as a matrix
data.L = create4connected(size(data.I,1), size(data.I,2), data.mask);

% get the constant term for the retinex gradient term
data.cret_deriv_term = computeCretDerivativeTerm(data);

% get an initial value of r -> r^0
r = rinitialize(data, 1);

% run k-means to find the initial alpha of all the points
rdotRd = bsxfun(@times, r, data.Rd);
rdotRd = reshape(rdotRd, size(r,1)*size(r,2), 3);
rdotRd_masked = rdotRd(data.mask(:),:);
fprintf('Running k-means - this can take a couple of mins\n');
[alpha, r_alpha_cntr] = kmeans(rdotRd_masked, settings.C, 'replicates',1, ...
                 'options',statset('MaxIter',1000));
fprintf('Done k-means\n');
alpha_clstr = zeros(size(r));
alpha_clstr(data.mask) = alpha;

% vectorize r and only keep values inside the mask
r = r(data.mask);


last_energy = inf;
curr_energy = -inf;

while last_energy - curr_energy > settings.diff_theta
    last_energy = curr_energy;
    
    % compute the total energy given the cluster assignment and reflectance
%     curr_energy = computeEnergy(r, alpha_clstr, r_alpha_cntr, data, settings);
    
    % optimize r given split
    r = minimize(r, @computeEnergy, ...
        struct('length', settings.minimize_max_iter, 'verbosity', 1), ...
        alpha_clstr, r_alpha_cntr, data, settings);
end
end


function r = rinitialize(data, iter)
% This function gives an initialization for r. There are 4 initializations
% - the one returned is according to the value given to iter
if iter == 1
    r = ones(size(data.Im));
else
    gammas = [0.3, 0.5, 0.7];
    gamma = gammas(iter-1);
    r = gamma*data.Im + 3*(1-gamma);
end
end


function nghb_masks = createNeighborhoodMasks(mask)
% create north masks
north_mask_i = mask & [false(1,size(mask,2)); mask(1:end-1,:)];
north_mask_j = [north_mask_i(2:end,:); false(1,size(mask,2))];

% create east masks
east_mask_i = mask & [mask(:,2:end) false(size(mask,1),1)];
east_mask_j = [false(size(mask,1),1) east_mask_i(:,1:end-1)];

% create south masks
south_mask_i = mask & [mask(2:end,:); false(1,size(mask,2))];
south_mask_j = [false(1,size(mask,2)); south_mask_i(1:end-1,:)];

% create west masks
west_mask_i = mask & [false(size(mask,1),1) mask(:,1:end-1)];
west_mask_j = [west_mask_i(:,2:end) false(size(mask,1),1)];

nghb_masks = cat(3, north_mask_i, north_mask_j, east_mask_i, east_mask_j, ...
                    south_mask_i, south_mask_j, west_mask_i, west_mask_j);
end