function g = computeReflectanceEdge(data, settings)
% Find if there is a reflectance edge between each pixel i and its 
% 4-connected pixel neighborhood (represented by j). The method is given
% after eq (5) in Gehler et al. NIPS 2011
%
% Inputs:
%   data.I - input RGB image
%   settings.theta_g - intensity gradient threshold
%   settings.theta_g - chromaticity gradient threshold
% 
% Outputs:
%   g - binary matrix giving reflectance edges between center pixel and the
%       4-connected pixel neighborhood. It is a stack of 4 logical matrices
%           g(:,:,1): when j is the north pixel
%           g(:,:,2): when j is the east pixel
%           g(:,:,3): when j is the south pixel
%           g(:,:,4): when j is the west pixel
% 
% Ahmad Humayun
% July 7, 2012

% replicate pixels at image boundaries to deal with boundary cases later on
I = data.I;
I = [I(1,:,:); I; I(end,:,:)];
I = [I(:,1,:) I I(:,end,:)];

% The three coordinates of CIELAB represent the lightness of the color 
% (L* = 0 yields black and L* = 100 indicates diffuse white; specular white 
% may be higher), its position between red/magenta and green (a*, negative 
% values indicate green while positive values indicate magenta) and its 
% position between yellow and blue (b*, negative values indicate blue and 
% positive values indicate yellow).
% Hence, 
% l* is associated to lightness / intensity
% a* and b* are associated with chromaticity

% convert image to l*a*b* -> http://en.wikipedia.org/wiki/CIELAB
cform = makecform('srgb2lab');
I_lab = applycform(I, cform);

% get the center image
center_I_lab = I_lab(2:end-1, 2:end-1, :);

% get the 4 images for the 4-connected neighborhood pixels
north_I_lab = I_lab(1:end-2, 2:end-1, :);
east_I_lab  = I_lab(2:end-1, 3:end,   :);
south_I_lab = I_lab(3:end,   2:end-1, :);
west_I_lab  = I_lab(2:end-1, 1:end-2, :);

% create an output matrix for g_{ij)(I) - its depth is 4, each dimension
% gives edges in different direction from the center pixel.
g = false(size(data.I,1), size(data.I,2), 4);

% compute the intensity difference
g(:,:,1) = isReflectanceEdge(center_I_lab, north_I_lab, settings);
g(:,:,2) = isReflectanceEdge(center_I_lab, east_I_lab, settings);
g(:,:,3) = isReflectanceEdge(center_I_lab, south_I_lab, settings);
g(:,:,4) = isReflectanceEdge(center_I_lab, west_I_lab, settings);
end


function g = isReflectanceEdge(I1_lab, I2_lab, settings)
% separate out the intensity / chromaticity channels
I1_intsty = I1_lab(:,:,1);
I2_intsty = I2_lab(:,:,1);
I1_chroma = I1_lab(:,:,[2 3]);
I2_chroma = I2_lab(:,:,[2 3]);

% compute if its a reflectance edge if we just look at intensity
g_int = abs(I1_intsty - I2_intsty) > settings.theta_g;

% compute if its a reflectance edge if we just look at chromaticity
%  - since it has two channels, use the L2 norm of the difference
g_chr = sqrt(sum((I1_chroma - I2_chroma).^2, 3)) > settings.theta_c;

% classify as reflectance edge only if is both by intensity and
% chromaticity
g = g_int & g_chr;
end
