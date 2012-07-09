function Eret = computeGradientConsistency(r, log_gradm_g, nghb_masks)
%COMPUTEGRADIENTCONSISTENCY Summary of this function goes here
%   Detailed explanation goes here

Eret = 0.0;

% compute the energy with the north neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,1))) - log(r(nghb_masks(:,:,2))) - ...
                   log_gradm_g{1}(nghb_masks(:,:,1))).^2);

% compute the energy with the east neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,3))) - log(r(nghb_masks(:,:,4))) - ...
                   log_gradm_g{1}(nghb_masks(:,:,3))).^2);

% compute the energy with the south neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,5))) - log(r(nghb_masks(:,:,6))) - ...
                   log_gradm_g{1}(nghb_masks(:,:,5))).^2);

% compute the energy with the west neighboring pixel
Eret = Eret + sum((log(r(nghb_masks(:,:,7))) - log(r(nghb_masks(:,:,8))) - ...
                   log_gradm_g{1}(nghb_masks(:,:,7))).^2);
end

