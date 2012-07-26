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

out_dir = fullfile(data_dir, 'best_k');

image_names = {'apple';'box';'cup1';'cup2';'deer';...
    'dinosaur';'frog1';'frog2';'panther';'paper1';'paper2';'pear'; ...
    'phone';'potato';'raccoon';'squirrel';'sun';'teabag1';'teabag2'; ...
    'turtle';'acorns'};

for idx = 1:length(image_names)
    idx
    
    % Select a particular image
    image_name = image_names{idx};
    % image_name = 'acorns';
    
    load(fullfile(data_dir, [image_name '_results.mat']))
    
    % skip if results empty
    if isempty(est_shading) || isempty(est_reflectance)
        continue;
    end
    
    s = imread(fullfile(data_dir, image_name, 'shading.png'));
    R = imread(fullfile(data_dir, image_name, 'reflectance.png'));
    mask = imread(fullfile(data_dir, image_name, 'mask.png'));
    
    s = im2double(s);
    R = im2double(R);
    mask = logical(mask);
    
    est_shading(est_shading < 0) = 0;
    est_reflectance(est_reflectance < 0) = 0;
    
    % find best k
    temp = s(mask) ./ est_shading(mask);
    temp(isinf(temp) | isnan(temp)) = [];
    k1 = mean(temp);
    
    tempR = reshape(R, [size(R,1)*size(R,2) 3]);
    tempEstR = reshape(est_reflectance, [size(R,1)*size(R,2) 3]);
    temp = 1 ./ (tempR(mask,:) ./ tempEstR(mask,:));
    temp = temp(:);
    temp(isinf(temp) | isnan(temp)) = [];
    k2 = mean(temp);
    
    k = mean([k1 k2]);
    
    % adjust shading and reflectance
    est_shading = k .* est_shading;
    est_shading(est_shading > 1) = 1;
    imshow(est_shading);
    imwrite(est_shading, fullfile(out_dir, [image_name '_est_shading.png']));
    
    est_reflectance = (1/k) .* est_reflectance;
    est_reflectance(est_reflectance > 1) = 1;
    imshow(est_reflectance);
    imwrite(est_reflectance, fullfile(out_dir, [image_name '_est_reflectance.png']));
end