function [Ecl, dEcl] = computeGlobalReflectancePrior(r, Rd, alpha, alpha_cntr, C, mask)
% Computes an energy function where each pixel's current reflectance value
% is compared to the cluster centers they belong to. The method is given in
% eq (6) in Gehler et al. NIPS 2011
%
% Inputs:
%   r - the reflectance scalar values (size of the image)
%   Rd - \vec{R}_i, the reflectance vector direction for each pixel
%   alpha - the cluster assignment for each pixel
%   alpha_cntr - the cluster centers for all basis colors
%   mask - binary mask, marking pixels to consider or ignore
% 
% Outputs:
%   Ecl - the final computed energy
% 
% Ahmad Humayun
% July 10, 2012

% r_i * \vec{R}_i
rdotRd = bsxfun(@times, r, Rd);
rdotRd = reshape(rdotRd, size(r,1)*size(r,2), 3);
rdotRd_masked = rdotRd(mask(:),:);

% compute the centroids for each cluster
alpha_mskd = alpha(mask);
alpha_cntr = zeros(C,3);
for c_idx = 1:size(alpha_cntr,1)
    alpha_cntr(c_idx,:) = mean(rdotRd_masked(alpha_mskd == c_idx, :), 1);
end

% difference of reflectance with the selected basis colors
diff = rdotRd_masked - alpha_cntr(alpha(mask),:);
%Ecl = sum(diff(:).^2);
Ecl = (1/3) * sum(diff(:).^2);

% compute the gradient
Rdr = reshape(Rd, [size(mask,1)*size(mask,2) 3]);
dEcl = (2/3) * sum(Rdr(mask(:),:) .* diff, 2);
end

