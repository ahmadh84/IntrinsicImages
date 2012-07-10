function energy = computeEnergy(r, alpha, alpha_cntr, data, settings)
% compute the current shading for each pixel -> s_i
S = data.Im ./ r;

% compute the shading prior energy
Es = computeShadingPrior(S, data.mask, data.nghb_masks);

% compute gradient consistency
Eret = computeGradientConsistency(r, data.log_gradm_g, data.nghb_masks);

% compute global sparse reflectance prior
Ecl = computeGlobalReflectancePrior(r, data.Rd, alpha, alpha_cntr, data.mask);

% complete energy as a weighted sum
energy = settings.w_s*Es + settings.w_r*Eret + settings.w_cl*Ecl;
end

