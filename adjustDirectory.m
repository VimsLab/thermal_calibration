function [] = adjustDirectory(dir_to_use, varargin)

%%%
% Input: dir_to_use is directory containing thermal data with subfolders
% dir_to_use/5003/, dir_to_use/5270. 
%
% This function will automatically create two new directories
% 5003_adjusted and 5270_adjusted which contain the preprocessed images
% using my method. It automatically overwrites those directories if they
% exist.
%
% Example: dir_to_use = './test_imgs';
%          adjustDirectory(dir_to_use);
%          stereoCameraCalibrator; %requires Matlab 2014b or later
% Then select Add Images -> ./test_imgs/5003_adjusted and ./test_imgs/5270_adjusted
%  and 23.1mm for the checkerboard size (per square). 
%
% Example2: adjustDirectory(dir_to_use, 0, 5, 15, 0.3, 0.8);

%Append a '/' if one doesnt exist at the end of the directory
if(dir_to_use(end) ~= '/')
    dir_to_use = [dir_to_use '/'];
end


%Remove 5003_adjusted and 5270_adjusted if they already exist
try
    rmdir([dir_to_use '5003_adjusted'], 's');
catch err
end

try
    rmdir([dir_to_use '5270_adjusted'], 's');
catch err
end

%Create 5003_adjusted and 5270_adjusted
mkdir([dir_to_use '5003_adjusted']);
mkdir([dir_to_use '5270_adjusted']);

dir1 = dir([dir_to_use '5003']); dir1 = dir1(3:end);
dir2 = dir([dir_to_use '5270']); dir2 = dir2(3:end);

%For every image in 5003/ and 5270/, run preprocess code and write the image
%to the new directory
for ii = 1:length(dir1)
    img1 = imread([dir_to_use '5003\' dir1(ii).name]);
    [img1] = preprocess_thermal(img1, varargin);
    imwrite(img1, [dir_to_use '5003_adjusted\' dir1(ii).name])
    
    img2 = imread([dir_to_use '5270\' dir2(ii).name]);
    
    [img2] = preprocess_thermal(img2, varargin);
    imwrite(img2, [dir_to_use '5270_adjusted\' dir2(ii).name])

    disp(['Adjusted image ' num2str(ii) ' out of ' num2str(length(dir1))]);
end

end