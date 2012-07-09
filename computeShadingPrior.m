function Es = computeShadingPrior(S, mask, nghb_masks)
% Compute shading prior as in Gehler et. al., 2011, eqn. 4
%
% Inputs:
%   S - shading image
%   mask - binary mask, marking pixels to consider or ignore
% 
% Outputs:
%   Es - shading prior, one of the terms to be minimized in the intrinsic
%       images algorithm by Gehler et. al., 2011, eqn. 3
% 
% Stephen Rosenthal
% July 7, 2012

% Start with zero for the shading prior
Es = 0;

[M, N] = size(S);
% 
% Es = sum((S(nghb_masks(:,:,1)) - S(nghb_masks(:,:,2))).^2);
% Es = Es + sum((S(nghb_masks(:,:,3)) - S(nghb_masks(:,:,4))).^2);
% Es = Es + sum((S(nghb_masks(:,:,5)) - S(nghb_masks(:,:,6))).^2);
% Es = Es + sum((S(nghb_masks(:,:,7)) - S(nghb_masks(:,:,8))).^2);

% For each pixel (skip border to avoid edge conditions)
for m = 2:M-1
    for n = 2:N-1
        % If inside the mask
        if mask(m, n)        
            % Consider a 4-connected neighborhood and add the sum of 
            % squared differences in shading to Es
            if mask(m - 1, n)
                Es = Es + (S(m - 1, n) - S(m, n)).^2;
            end

            if mask(m + 1, n)
                Es = Es + (S(m + 1, n) - S(m, n)).^2;
            end

            if mask(m, n - 1)
                Es = Es + (S(m, n - 1) - S(m, n)).^2;
            end

            if mask(m, n + 1)
                Es = Es + (S(m, n + 1) - S(m, n)).^2;
            end
        end
    end
end