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
    'turtle';'acorns'};

for idx = 1:length(image_names)
    % Select a particular image
    image_name = image_names{idx};
    % image_name = 'acorns';

    I = imread(fullfile(data_dir, image_name, 'diffuse.png'));
    s = imread(fullfile(data_dir, image_name, 'shading.png'));
    R = imread(fullfile(data_dir, image_name, 'reflectance.png'));
    mask = imread(fullfile(data_dir, image_name, 'mask.png'));

    % Plot the image components
    % figure(1); imshow(I); title('Original');
    % figure(2); imshow(s); title('Shading (Ground Truth)');
    % figure(3); imshow(R); title('Reflectance (Ground Truth)');
    % figure(4); imshow(mask); title('Mask');

    % Convert all image components to double for computation
    % Since only relative scaling matters, convert to interval [0, 1]
    % I = mat2gray(I);
    % s = mat2gray(s);
    % R = mat2gray(R);
    mask = logical(mask);

    % Test LMSE computation
    % LMSE = computeScore(s, s + 30*rand(size(s)), R, R + 30*rand(size(R)), mask);

    % [s, R] = coordinateDescent(I, mask);
    tic;
    [est_shading, est_reflectance, score, best_r_init] = coordinateDescent(I, mask, s, R);
    time_elapsed = toc;

    save(fullfile(data_dir, [image_name '_results.mat']), 'est_shading', 'est_reflectance', 'score', 'best_r_init', 'time_elapsed');
end