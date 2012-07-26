function [ est_reflectance est_shading ] = displayOutput(r, Rd, I, Im, mask, iter)
%DISPLAYOUTPUT Summary of this function goes here
%   Detailed explanation goes here

    Rd_vec = reshape(Rd, [size(Rd,1)*size(Rd,2) 3]);
    rdotRd = bsxfun(@times, r, Rd_vec(mask(:),:));
    
    % for visualizing the reflectance and shading
    est_reflectance = zeros([size(I,1)*size(I,2) 3]);
    est_reflectance(mask(:),:) = rdotRd;
    est_reflectance = reshape(est_reflectance, size(I));
    
    full_r = zeros(size(mask));
    full_r(mask) = r;
    est_shading = Im ./ full_r;
    est_shading(~mask) = 0;
    
    % visualize interim results
    subplot(1, 2, 1);
    image(getNormalized(est_reflectance));
    title(sprintf('Estimated Reflectance - iteration %d', iter));
    subplot(1, 2, 2);
    image(getNormalized(repmat(est_shading, [1, 1, 3])));
    title(sprintf('Estimated Shading - iteration %d', iter));
    drawnow;
end


function i = getNormalized(i)
mx = max(i(:));
mn = min(i(:));

i = (i - mn) ./ (mx - mn);
end
