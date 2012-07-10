function Eret = computeGradientConsistency(r, log_gradm_g, nghb_masks)
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

% compute the energy with the north neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,1))) - log(r(nghb_masks(:,:,2))) - ...
                   log_gradm_g{1}(nghb_masks(:,:,1))).^2);

% compute the energy with the east neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,3))) - log(r(nghb_masks(:,:,4))) - ...
                   log_gradm_g{2}(nghb_masks(:,:,3))).^2);

% compute the energy with the south neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,5))) - log(r(nghb_masks(:,:,6))) - ...
                   log_gradm_g{3}(nghb_masks(:,:,5))).^2);

% compute the energy with the west neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,7))) - log(r(nghb_masks(:,:,8))) - ...
                   log_gradm_g{4}(nghb_masks(:,:,7))).^2);
end

