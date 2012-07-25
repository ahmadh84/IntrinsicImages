function [ cretDerivativeTerm ] = computeCretDerivativeTerm(data)
%COMPUTECRETDERIVATIVETERM Summary of this function goes here
%   Detailed explanation goes here

% thresholdGray   = 0.075;
% thresholdColor  = 1;
% 
% [m, n] = size(data.mask);
% 
% [filterH, filterV] = create4connected_L1(m, n, data.mask);
% 
% diffuse = data.I;
% diffuse = reshape(diffuse, m*n, 3);
% diffuse = diffuse(data.mask(:),:);
% 
% self.estH = colorRetEstimator(diffuse, filterH, ...
% thresholdGray, thresholdColor);
% self.estV = colorRetEstimator(diffuse, filterV, ...
% thresholdGray, thresholdColor);
% 
% self.cretDerivativeTerm = filterH'*self.estH + filterV'*self.estV;

vert_derivative = data.log_gradm_g{1};
vert_derivative(data.nghb_masks(:,:,1)) = ...
                data.log_gradm_g{1}(data.nghb_masks(:,:,2)) - ...
                data.log_gradm_g{1}(data.nghb_masks(:,:,1));

horz_derivative = data.log_gradm_g{4};
horz_derivative(data.nghb_masks(:,:,7)) = ...
                data.log_gradm_g{4}(data.nghb_masks(:,:,8)) - ...
                data.log_gradm_g{4}(data.nghb_masks(:,:,7));

cretDerivativeTerm = vert_derivative + horz_derivative;
cretDerivativeTerm = cretDerivativeTerm(data.mask);
end

function [est] = colorRetEstimator(diffuse, op, thresholdGray, thresholdColor)
  cut = 3./(2^16 - 1);

  channels = size(diffuse, 2);

  diffuse(diffuse < cut) = cut;
  logDiffuse = log(diffuse);

  for i=1:channels
    responseOrig(:, i) = op * logDiffuse(:, i);
  end
  responseGray = projectGray(responseOrig);
  responseColor = projectColor(responseOrig);
  normedResponseColor = sqrt(sum(responseColor.^2, 2));

  logDiffuseGrayscale = log(mean(diffuse, 2));
  responseGrayscale = op * logDiffuseGrayscale;

  est = responseGrayscale .* ...
    double(normedResponseColor > thresholdColor ...
         | abs(responseGray(:, 1)) > thresholdGray);
end

function [p] = projectGray(e)
  p = repmat(mean(e, 2), [1, 3]);
end

function [p] = projectColor(e)
  p = e - projectGray(e);
end