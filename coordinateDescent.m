function [best_est_shading, best_est_reflectance, best_score, best_r_init] = coordinateDescent(I, mask, true_shading, true_reflectance)
% Computes the intrinsic image separation of the reflectance and shading
% using algorithm 1 in Gehler et al. NIPS 2011. This is a coordinate 
% descent solution to eq (3) in the paper.
%
% Inputs:
%   I - input RGB image
%   mask - binary mask giving the location of the object
%   true_shading - true shading, same width and height as I
%   true_reflectance - true reflectance, 3 channels, same size as I
% 
% Outputs:
%   est_shading - estimated shading, same width and height as I
%   est_reflectance - estimated reflectance, 3 channels, same size as I
%   score - LMSE-based score comparing estimated shading and reflectance to
%       true values
% 
% Ahmad Humayun
% July 11, 2012

settings.theta_g = 0.075;       % threshold for intensity edge
settings.theta_c = 1;           % threshold for chromaticity edge
settings.C = 25;                % number of basis color clusters
settings.kmeans_repl = 1;       % number kmeans replicates

settings.w_s = 1e-3;            % the weight for shading smoothness term
settings.w_r = 1e-2;            % the weight for gradient consistency term
settings.w_cl = 1;              % the weight for global sparse reflectance 
                                % prior

settings.diff_theta = 1e-5;     % terminate looping if the difference in 
                                % energy between iteration is less than this 
                                % value

settings.minimize_max_iter = 1e4;
settings.max_iterations   = 250;

% add libraries to the path
curr_dir = fileparts(which(mfilename));
addpath(genpath(fullfile(curr_dir, 'libs')));

% check for all variables
if exist('I','var')~=1 || exist('mask','var')~=1 || ...
   exist('true_shading','var')~=1 || exist('true_reflectance','var')~=1
    error('coordinateDescent:Arguments', 'missing arguments');
end

% check if its a color image
assert(size(I,3) == 3, 'This algorithm only works on color images');

% convert to input image to double and mask to binary for consistency
data.I = im2double(I);
% data.I = double(I) ./ (2^16-1);
data.mask = logical(mask);

%%%%%%%%%%%%%% Compute constants for the algorithm %%%%%%%%%%%%%%
% compute magnitude (l1 norm) of each pixel -> ||I_i||_1
data.Im = sum(data.I, 3);

% compute reflectance direction -> \vec{R}_i
data.Rd = bsxfun(@times, data.I, 1./data.Im);

data.nghb_masks = createNeighborhoodMasks(data.mask);

% find the reflectance edges btw pixel i and j (4-connected neighborhood)
data.g = computeReflectanceEdge(data, settings);
data.g2 = computeReflectanceEdge2(data, settings);

% compute log image gradient multiplied only at reflectance edges (used by
% gradient consistency - retinex term E_{ret})
data.log_gradm_g = computeLogGradMagEdge(data);

% Create discrete Laplacian operator as a matrix
data.L = create4connected(size(data.I,1), size(data.I,2), data.mask);

% get the constant term for the retinex gradient term
data.cret_deriv_term = computeCretDerivativeTerm(data);

best_est_shading = [];
best_est_reflectance = [];
best_score = inf;
best_r_init = [];

% loop over different r initial values
for r_idx = 1:4
    % get an initial value of r -> r^0
    r = rinitialize(data, r_idx);

    % run k-means to find the initial alpha of all the points
    rdotRd = bsxfun(@times, r, data.Rd);
    rdotRd = reshape(rdotRd, size(r,1)*size(r,2), 3);
    rdotRd_masked = rdotRd(data.mask(:),:);
    fprintf('Running k-means - this can take a couple of mins\n');
    [alpha, r_alpha_cntr] = kmeans(rdotRd_masked, settings.C, ...
                                   'replicates',settings.kmeans_repl, ...
                                   'options',statset('MaxIter',1000));
    fprintf('Done k-means\n');
    alpha_clstr = nan(size(r));
    alpha_clstr(data.mask) = alpha;

    % vectorize r and only keep values inside the mask
    r = r(data.mask);

    Rd_vec = reshape(data.Rd, [size(data.Rd,1)*size(data.Rd,2) 3]);
    Rd_vec = Rd_vec(data.mask(:),:);

    last_energy = inf;
    curr_energy = 1e20;
    
    iter = 0;

    % main loop (loop until energy change is smaller than a threshold or the
    % number of iterations exceed some threshold)
    while last_energy - curr_energy > settings.diff_theta
        last_energy = curr_energy;

        % optimize r using BFGS
        [r, e] = minimize(r, @computeEnergy, ...
            struct('length', settings.minimize_max_iter, 'verbosity', 1), ...
            alpha_clstr, r_alpha_cntr, data, settings);

        curr_energy = e(end);

        % check if the energy is decreasing (will then automagically will
        % use the last estimated reflectance and shading)
        if last_energy < curr_energy
            warning('coordinateDescent:energyIncrease', 'The energy increased in this optimization iteration');
            break;
        end

        % find new cluster centers
        rdotRd = bsxfun(@times, r, Rd_vec);
        alpha_clstr_vec = alpha_clstr(data.mask);
        for c_idx = 1:size(r_alpha_cntr,1)
            r_alpha_cntr(c_idx,:) = mean(rdotRd(alpha_clstr_vec == c_idx, :), 1);
        end

        % assign new cluster indices with new cluster centers
        alpha_clstr_mskd = zeros(size(rdotRd,1),1);
        for p_idx = 1:size(alpha_clstr_mskd,1)
          dists = sum(bsxfun(@minus, rdotRd(p_idx,:), r_alpha_cntr).^2, 2);
          [dist alpha_clstr_mskd(p_idx)] = min(dists);
        end
        alpha_clstr = nan(size(data.mask));
        alpha_clstr(data.mask) = alpha_clstr_mskd;

        % plot
        iter = iter + 1;

        % throw away the imaginary part
        r = real(r);

        [ est_reflectance est_shading ] = displayOutput(r, data.Rd, data.I, data.Im, data.mask, iter);

        % in case the loop has exceeded the max # of iterations
        if iter >= settings.max_iterations
            warning('coordinateDescent:prematureEnd', 'The maximum number of iterations for the optimization were reached');
            break;
        end
    end

    score = computeScore(true_shading, est_shading, true_reflectance, est_reflectance, mask);
    
    % if better than other r initializations
    if score < best_score
        best_est_shading = est_shading;
        best_est_reflectance = est_reflectance;
        best_score = score;
        best_r_init = r_idx;
    end
end

% fin
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
