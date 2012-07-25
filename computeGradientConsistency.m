function [Eret, dEret] = computeGradientConsistency(r, log_gradm_g, g2, cret_deriv_term, L, nghb_masks, mask)
% Computes an energy function where an object can't be explained either by
% shading or reflectance change. The method is given in eq (5) in 
% Gehler et al. NIPS 2011
%
% Inputs:
%   r - the reflectance scalar values (size of the image)
%   log_gradm_g - g_{ij}(I)[log(|I_i|) - log(|I_j|)]
%   nghb_masks - cell array of size 4 each containing a pair of 
%       neighborhood masks in each compass direction
% 
% Outputs:
%   Eret - the final computed energy
% 
% Ahmad Humayun
% July 8, 2012

Eret = 0.0;

% compute the log of r to be used both in computing energy and its deriv.
log_r = log(r+eps);

% compute the energy with the north neighboring pixel
% Eret = Eret + sum((log_r(nghb_masks(:,:,1)) - log_r(nghb_masks(:,:,2)) - ...
%                    log_gradm_g{1}(nghb_masks(:,:,1))).^2);
% 
% % compute the energy with the east neighboring pixel
% Eret = Eret + sum((log_r(nghb_masks(:,:,3)) - log_r(nghb_masks(:,:,4)) - ...
%                    log_gradm_g{2}(nghb_masks(:,:,3))).^2);
% 
% % compute the energy with the south neighboring pixel
% Eret = Eret + sum((log_r(nghb_masks(:,:,5)) - log_r(nghb_masks(:,:,6)) - ...
%                    log_gradm_g{3}(nghb_masks(:,:,5))).^2);
% 
% % compute the energy with the west neighboring pixel
% Eret = Eret + sum((log_r(nghb_masks(:,:,7)) - log_r(nghb_masks(:,:,8)) - ...
%                    log_gradm_g{4}(nghb_masks(:,:,7))).^2);


temp = log_r(nghb_masks(:,:,2)) - log_r(nghb_masks(:,:,1));
filtered_nr = zeros(size(mask));
filtered_nr(nghb_masks(:,:,1)) = temp;
temp = log_r(nghb_masks(:,:,4)) - log_r(nghb_masks(:,:,3));
filtered_er = zeros(size(mask));
filtered_er(nghb_masks(:,:,3)) = temp;
temp = log_r(nghb_masks(:,:,6)) - log_r(nghb_masks(:,:,5));
filtered_sr = zeros(size(mask));
filtered_sr(nghb_masks(:,:,5)) = temp;
temp = log_r(nghb_masks(:,:,8)) - log_r(nghb_masks(:,:,7));
filtered_wr = zeros(size(mask));
filtered_wr(nghb_masks(:,:,7)) = temp;

laplacian_r = -filtered_nr - filtered_er - filtered_sr - filtered_wr;

Eret = log_r .* laplacian_r;
Eret = sum(Eret(mask));

temp = (g2(:,:,1) .* filtered_nr) + (g2(:,:,2) .* filtered_wr);
temp = sum(temp(mask));
Eret = Eret - 2*temp;

% compute the derivative
% laplacian_r = L * log_r(mask);
dEret =  2*laplacian_r(mask) - 2*cret_deriv_term;
dEret = dEret ./ r(mask);
end

