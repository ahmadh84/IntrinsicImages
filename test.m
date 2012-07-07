image_names = {'apple';'box';'cup1';'cup2';'deer';'desktop.ini'; ...
    'dinosaur';'frog1';'frog2';'panther';'paper1';'paper2';'pear'; ...
    'phone';'potato';'raccoon';'squirrel';'sun';'teabag1';'teabag2'; ...
    'turtle'};
idx = 1;    % Select a particular image

I = imread(fullfile('..', 'data', image_names{idx}, 'original.png'));
s = imread(fullfile('..', 'data', image_names{idx}, 'shading.png'));
R = imread(fullfile('..', 'data', image_names{idx}, 'reflectance.png'));
mask = imread(fullfile('..', 'data', image_names{idx}, 'mask.png'));

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
k = 20;
LMSE = computeScore(s, s + rand(size(s)), R, R + rand(size(R)), mask, k);

% Test shading prior (Es) computation
Es = computeShadingPrior(s, mask);