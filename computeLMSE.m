function LMSE = computeLMSE(S, S_hat, mask, k)
% Compute local MSE as in Grosse et. al., 2009, eqn. 8
%
% Inputs:
%   S - true image
%   S_hat - predicted image, same size as S
%   mask - binary mask, marking pixels to consider or ignore
%   k - window size (integer number of pixels)
% 
% Outputs:
%   LMSE - scale-invariant local mean squared error
% 
% Stephen Rosenthal
% July 4, 2012

LMSE = 0;
[M, N, P] = size(S);

% If no mask provided, use all pixels
if ~exist('mask', 'var')
    mask = true(M, N);
end

% Set default value for k
if ~exist('k', 'var')
    k = 20;
end

% For each block of size k-by-k and spaced by k/2
for left = 1:k/2:M-k
    for top = 1:k/2:N-k
        for channel = 1:P
            S_w = S(left:left+k-1, top:top+k-1, channel);
            S_hat_w = S_hat(left:left+k-1, top:top+k-1, channel);
            mask_w = mask(left:left+k-1, top:top+k-1);

            % Compute scale-invariant MSE and sum
            if any(mask_w(:))   % Skip this window if outside the mask
                LMSE = LMSE + computeMSE(S_w, S_hat_w, mask_w);
            end
        end
    end
end

LMSE = 1000 * LMSE;

end