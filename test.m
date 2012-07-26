if strcmp(getenv('USERNAME'), 'Steve') % Point to Steve's data directory
    data_dir = fullfile('..', 'data');
else % Point to Ahmad's data directory
    if ispc
        user_dir = getenv('USERPROFILE');
    else
        user_dir = getenv('HOME');
    end
    data_dir = fullfile(user_dir, 'Dropbox', 'IntrinsicImageData');
end

image_names = {'apple';'box';'cup1';'cup2';'deer';'desktop.ini'; ...
    'dinosaur';'frog1';'frog2';'panther';'paper1';'paper2';'pear'; ...
    'phone';'potato';'raccoon';'squirrel';'sun';'teabag1';'teabag2'; ...
    'turtle'};
idx = 18;    % Select a particular image

I = imread(fullfile(data_dir, image_names{idx}, 'diffuse.png'));
s = imread(fullfile(data_dir, image_names{idx}, 'shading.png'));
R = imread(fullfile(data_dir, image_names{idx}, 'reflectance.png'));
mask = imread(fullfile(data_dir, image_names{idx}, 'mask.png'));

% Plot the image components
% figure(1); imshow(I); title('Original');
% figure(2); imshow(s); title('Shading (Ground Truth)');
% figure(3); imshow(R); title('Reflectance (Ground Truth)');
% figure(4); imshow(mask); title('Mask');

% Convert all image components to double for computation
% Since only relative scaling matters, convert to interval [0, 1]
I = mat2gray(I);
s = mat2gray(s);
R = mat2gray(R);
mask = logical(mask);

% Test LMSE computation
% LMSE = computeScore(s, s + 30*rand(size(s)), R, R + 30*rand(size(R)), mask);

% [s, R] = coordinateDescent(I, mask);
[est_shading, est_reflectance, score] = coordinateDescent(I, mask, s, R);