function [energy, dEnergy] = computeEnergy(r, alpha, alpha_cntr, data, settings)

full_r = zeros(size(data.mask));
full_r(data.mask) = r;

energy = 0;
dEnergy = zeros(size(r));

% compute the shading prior energy
if settings.w_s ~= 0
    [Es, dEs] = computeShadingPrior(data.Im, full_r, data.L, data.mask);

    energy = energy + settings.w_s*Es;          % add energy as a weighted sum
    dEnergy = dEnergy + settings.w_s*dEs;       % add energy's partial derivative
end

% compute gradient consistency
if settings.w_r ~= 0
    [Eret, dEret] = computeGradientConsistency(full_r, data.log_gradm_g, data.g2, data.cret_deriv_term, data.L, data.nghb_masks, data.mask);

    energy = energy + settings.w_r*Eret;        % add energy as a weighted sum
    dEnergy = dEnergy + settings.w_r*dEret;     % add energy's partial derivative
end

% compute global sparse reflectance prior
if settings.w_cl ~= 0
    [Ecl, dEcl] = computeGlobalReflectancePrior(full_r, data.Rd, alpha, alpha_cntr, settings.C, data.mask);

    energy = energy + settings.w_cl*Ecl;        % add energy as a weighted sum
    dEnergy = dEnergy + settings.w_cl*dEcl;     % add energy's partial derivative
end

% project the gradient back such that mean(r) does not change
dEnergy = dEnergy - mean(dEnergy(:));
end
