function energy = computeEnergy(r, alpha, alpha_cntr, data, settings)

% compute the shading prior energy
[Es, dEs] = computeShadingPrior(data.Im, r, data.mask);

% compute gradient consistency
Eret = computeGradientConsistency(r, data.log_gradm_g, data.nghb_masks);

% compute global sparse reflectance prior
Ecl = computeGlobalReflectancePrior(r, data.Rd, alpha, alpha_cntr, data.mask);

% complete energy as a weighted sum
energy = settings.w_s*Es + settings.w_r*Eret + settings.w_cl*Ecl;

% compute partial derivative of energy with respect to elements of r
% dEnergy = settings.w_s*dEs + settings.w_r*dEr + settings.w_cl*dEcl;

end

