function g = computeReflectanceEdge(data, settings)
% Find if there is a reflectance edge between each pixel i and its 
% 4-connected pixel neighborhood (represented by j). The method is given
% after eq (5) in Gehler et al. NIPS 2011
%
% Note that the answer for the north and south / west and east neighborhood
% should be equivalent!
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

cut = 3/(2^16-1);
I = data.I;
I(I < cut) = cut;
  
% replicate pixels at image boundaries to deal with boundary cases later on
log_I = log(I);
log_I = [log_I(1,:,:); log_I; log_I(end,:,:)];
log_I = [log_I(:,1,:) log_I log_I(:,end,:)];

% get the center image
center_log_I = log_I(2:end-1, 2:end-1, :);

% get the 4 images for the 4-connected neighborhood pixels
north_log_I = log_I(1:end-2, 2:end-1, :);
% east_log_I  = log_I(2:end-1, 3:end,   :);
% south_log_I = log_I(3:end,   2:end-1, :);
west_log_I  = log_I(2:end-1, 1:end-2, :);

v_filtered_log_I = north_log_I - center_log_I;
h_filtered_log_I = west_log_I - center_log_I;

v_gray_response = repmat(mean(v_filtered_log_I, 3), [1 1 3]);
h_gray_response = repmat(mean(h_filtered_log_I, 3), [1 1 3]);

v_color_response = v_filtered_log_I - v_gray_response;
h_color_response = h_filtered_log_I - h_gray_response;

v_norm_color_response = sqrt(sum(v_color_response.^2, 3));
h_norm_color_response = sqrt(sum(h_color_response.^2, 3));


log_I_gr = log(mean(I,3));
log_I_gr = [log_I_gr(1,:,:); log_I_gr; log_I_gr(end,:,:)];
log_I_gr = [log_I_gr(:,1,:) log_I_gr log_I_gr(:,end,:)];

% get the center image
center_log_I_gr = log_I_gr(2:end-1, 2:end-1, :);

% get the 4 images for the 4-connected neighborhood pixels
north_log_I_gr = log_I_gr(1:end-2, 2:end-1, :);
% east_log_I_gr  = log_I_gr(2:end-1, 3:end,   :);
% south_log_I_gr = log_I_gr(3:end,   2:end-1, :);
west_log_I_gr  = log_I_gr(2:end-1, 1:end-2, :);

v_filtered_log_I_gr = north_log_I_gr - center_log_I_gr;
h_filtered_log_I_gr = west_log_I_gr - center_log_I_gr;


% compute the edges in both direction
est_v = v_filtered_log_I_gr .* ...
            double(v_norm_color_response > settings.theta_c | ...
                   abs(v_gray_response(:,:,1)) > settings.theta_g);
est_h = h_filtered_log_I_gr .* ...
            double(h_norm_color_response > settings.theta_c | ...
                   abs(h_gray_response(:,:,1)) > settings.theta_g);
               
g(:,:,1) = est_v;
g(:,:,2) = est_h;
end
