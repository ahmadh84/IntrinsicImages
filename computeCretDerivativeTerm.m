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

vert_derivative = zeros(size(data.mask));
v_g2 = data.g2(:,:,1);
vert_derivative(data.nghb_masks(:,:,2)) = ...
                v_g2(data.nghb_masks(:,:,1)) - ...
                v_g2(data.nghb_masks(:,:,2));

horz_derivative = zeros(size(data.mask));
h_g2 = data.g2(:,:,2);
horz_derivative(data.nghb_masks(:,:,8)) = ...
                h_g2(data.nghb_masks(:,:,7)) - ...
                h_g2(data.nghb_masks(:,:,8));

cretDerivativeTerm = vert_derivative + horz_derivative;
cretDerivativeTerm = cretDerivativeTerm(data.mask);
end
