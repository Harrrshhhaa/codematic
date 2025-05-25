clc;
clear;
close all;

% Ask user to upload image(s)
[fileNames, pathName] = uigetfile({'*.jpg;*.png;*.jpeg','Image Files (*.jpg, *.png, *.jpeg)'}, ...
                                   'Select MRI Image(s)', 'MultiSelect', 'on');

% Handle single or multiple file uploads
if ischar(fileNames)
    fileNames = {fileNames};
end

% Process each uploaded image
for i = 1:length(fileNames)
    fprintf('Processing %s...\n', fileNames{i});
    
    % Full path of selected image
    imgPath = fullfile(pathName, fileNames{i});
    
    % Read image
    img = imread(imgPath);

    % Resize original image to 256x256 to match processing
    img_resized = imresize(img, [256 256]);

    % Convert to grayscale if needed
    if size(img_resized, 3) == 3
        gray_img = rgb2gray(img_resized);
    else
        gray_img = img_resized;
    end
    
    % Show Original Image
    figure, imshow(gray_img), title(['Original MRI - ', fileNames{i}]);

    % Median Filtering
    filtered_img = medfilt2(gray_img, [3 3]);
    figure, imshow(filtered_img), title('Filtered Image');

    % Segmentation using Otsu's Method
    level = graythresh(filtered_img);
    bw_img = imbinarize(filtered_img, level);
    figure, imshow(bw_img), title('Binary Segmented Image');

    % Morphological Cleaning
    bw_clean = bwareaopen(bw_img, 50);
    bw_filled = imfill(bw_clean, 'holes');
    figure, imshow(bw_filled), title('Morphologically Cleaned Image');

    % Edge Detection
    edges = edge(bw_filled, 'canny');
    figure, imshow(edges), title('Detected Tumor Edges');

    % Overlay on resized original image
    overlay_img = imoverlay(img_resized, edges, [1 0 0]);
    figure, imshow(overlay_img), title(['Tumor Detected - ', fileNames{i}]);
    
    fprintf('Completed %s\n\n', fileNames{i});
end

disp('All selected images processed successfully!');