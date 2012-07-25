function [Es, dEs] = computeShadingPrior(Im, r, L, mask) %, nghb_masks)
% Compute shading prior as in Gehler et. al., 2011, eqn. 4
%
% Inputs:
%   Im - norm (magnitude) of each pixel in image
%   r - the reflectance scalar values
%   mask - binary mask, marking pixels to consider or ignore
% 
% Outputs:
%   Es - shading prior, one of the terms to be minimized in the intrinsic
%       images algorithm by Gehler et. al., 2011, eqn. 3
%   dEs - partial derivatives of Es with respect to each element of r
% 
% Stephen Rosenthal
% July 7, 2012

s = Im ./ r;

[M, N] = size(s);
 
% Es = sum((s(nghb_masks(:,:,1)) - s(nghb_masks(:,:,2))).^2);
% Es = Es + sum((s(nghb_masks(:,:,3)) - s(nghb_masks(:,:,4))).^2);
% Es = Es + sum((s(nghb_masks(:,:,5)) - s(nghb_masks(:,:,6))).^2);
% Es = Es + sum((s(nghb_masks(:,:,7)) - s(nghb_masks(:,:,8))).^2);

% % Naive method: For each pixel (skip border to avoid edge conditions)
% Es = 0; % Start with zero for the shading prior
% 
% for m = 2:M-1
%     for n = 2:N-1
%         % If inside the mask
%         if mask(m, n)        
%             % Consider a 4-connected neighborhood and add the sum of 
%             % squared differences in shading to Es
%             if mask(m - 1, n)
%                 Es = Es + (s(m - 1, n) - s(m, n)).^2;
%             end
% 
%             if mask(m + 1, n)
%                 Es = Es + (s(m + 1, n) - s(m, n)).^2;
%             end
% 
%             if mask(m, n - 1)
%                 Es = Es + (s(m, n - 1) - s(m, n)).^2;
%             end
% 
%             if mask(m, n + 1)
%                 Es = Es + (s(m, n + 1) - s(m, n)).^2;
%             end
%         end
%     end
% end

% Fastest method: used in code for NIPS 2011
% Es = 2 * s(mask).' * L * s(mask);
Es = s(mask).' * L * s(mask);
dEs = -2 * L * s(mask) .* Im(mask) ./ r(mask).^2; % SJR Note: NIPS 2011 paper adds eps in denominator
