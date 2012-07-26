function score = computeScore(S, S_hat, R, R_hat, mask, k)
% Compute local MSE as in Grosse et. al., 2009, eqn. 9
%
% Inputs:
%   S - true shading image
%   S_hat - predicted shading image, same size as S
%   R - true reflectance image
%   R_hat - predicted reflectance image, same size as R
%   mask - binary mask, marking pixels to consider or ignore
%   k - window size (integer number of pixels)
% 
% Outputs:
%   score - average of LMSE scores, normalized so an estimate of all zeros
%       has the maximum possible score of 1
% 
% Stephen Rosenthal
% July 4, 2012

% If no mask provided, use all pixels
if ~exist('mask', 'var')
    mask = true(size(S));
end

% Set default value for k
if ~exist('k', 'var')
    k = 20;
end

num1 = computeLMSE(S, S_hat, mask, k);
den1 = computeLMSE(S, zeros(size(S)), mask, k);
num2 = computeLMSE(R, R_hat, mask, k);
den2 = computeLMSE(R, zeros(size(R)), mask, k);

score = (1/2) * num1 / den1 + (1/2) * num2 / den2;

score = score * 1000; % Multiply by 1000 as in NIPS 2011