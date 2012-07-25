function [energy, dEnergy] = computeEnergy(r, alpha, alpha_cntr, data, settings)

full_r = zeros(size(data.mask));
full_r(data.mask) = r;

% compute the shading prior energy
[Es, dEs] = computeShadingPrior(data.Im, full_r, data.L, data.mask);

% compute gradient consistency
[Eret, dEret] = computeGradientConsistency(full_r, data.log_gradm_g, data.cret_deriv_term, data.L, data.nghb_masks, data.mask);

% compute global sparse reflectance prior
[Ecl, dEcl] = computeGlobalReflectancePrior(full_r, data.Rd, alpha, alpha_cntr, data.mask);

% complete energy as a weighted sum
energy = settings.w_s*Es + settings.w_r*Eret + settings.w_cl*Ecl;

% compute partial derivative of energy with respect to elements of r
dEnergy = settings.w_s*dEs + settings.w_r*dEret + settings.w_cl*dEcl;

% project the gradient back such that mean(r) does not change
dEnergy = dEnergy - mean(dEnergy(:));
end
