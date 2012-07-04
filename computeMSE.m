function MSE = computeMSE(x, x_hat, mask)
% Compute scale-invariant MSE as in Grosse et. al., 2009, eqn. 7
%
% Inputs:
%   x - true image or subimage
%   x_hat - predicted image or subimage, same size as x
%   mask - binary mask, marking pixels to consider or ignore
% 
% Outputs:
%   MSE - scale-invariant mean squared error, where x_hat is multiplied by
%       a scalar to minimize the MSE between x and x_hat
% 
% Stephen Rosenthal
% July 4, 2012

% If no mask provided, use all pixels
if ~exist('mask', 'var')
    mask = true(size(x));
end

% Compute optimal scaling factor
alpha_hat = dot(x(mask(:)), x_hat(mask(:))) / ...
    dot(x_hat(mask(:)), x_hat(mask(:)));

% If x_hat is zero, then alpha will be NaN (division by zero); reset to 1
if isnan(alpha_hat)
   alpha_hat = 1; 
end

% Compute MSE (Note: The Grosse paper has this written as a SUM of squared
% errors rather than MEAN square error)
MSE = mean((x(mask(:)) - alpha_hat * x_hat(mask(:))).^2);

end