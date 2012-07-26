vec = @(x) x(:);

data_path = 'C:\Users\Steve\Dropbox\CS 7641 - Machine Learning\IntrinsicImages\data\';
name = 'paper2';
diffuse = imread(fullfile(data_path, name, 'diffuse.png'));
reflectance = imread(fullfile(data_path, name, 'reflectance.png'));
mask = imread(fullfile(data_path, name, 'mask.png'));

diffuse = mat2gray(diffuse);
diffuse_r = diffuse(:, :, 1);
diffuse_g = diffuse(:, :, 2);
diffuse_b = diffuse(:, :, 3);
reflectance = mat2gray(reflectance);
reflectance_r = reflectance(:, :, 1);
reflectance_g = reflectance(:, :, 2);
reflectance_b = reflectance(:, :, 3);
mask = logical(mask);

figure(1);
plot3(vec(diffuse_r(mask)), vec(diffuse_g(mask)), vec(diffuse_b(mask)), '.', 'MarkerSize', 1);
grid on;
az = 45;
el = 25;
view(az, el);
axis tight;
xlabel('Red'); ylabel('Green'); zlabel('Blue');
set(gca, 'FontSize', 16);
export_fig(fullfile(data_path, 'diffuse_RGB_scatterplot.png'), '-m0.6', '-transparent');

figure(2);
plot3(vec(reflectance_r(mask)), vec(reflectance_g(mask)), vec(reflectance_b(mask)), '.', 'MarkerSize', 1);
grid on;
view(az, el);
axis tight;
xlabel('Red'); ylabel('Green'); zlabel('Blue');
set(gca, 'FontSize', 16);
export_fig(fullfile(data_path, 'reflectance_RGB_scatterplot.png'), '-m0.6', '-transparent');