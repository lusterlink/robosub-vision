function [ test_set, labels ] = load_test(rotate_images )
%load_test Loads the test set 
%          The test set is designed for all the test samples
%
%           The following convention will be used, 
%           -1 is none
%           98 is 1
%           37 is 2
%           16 is 3
%           10 is 4
    positive_directories = ['98_test'; '37_test'; '16_test'; '10_test'];
    
    NUM_POS = 300;
    NUM_EMPTY_NEG = 250;
    NUM_GENERAL_NEG = 250;
    NUM_OVERALL = NUM_POS + NUM_EMPTY_NEG + NUM_GENERAL_NEG;
    
    test_set = zeros(640*480, NUM_OVERALL, 'uint8');
    labels = -1 * ones(NUM_OVERALL, 1, 'int8');
    
    index = 1;

    % Load positive images from each class
    fprintf('Loading %d positive images.\n', NUM_POS);
    for j=1:size(positive_directories, 1)
        for c=1:NUM_POS/size(positive_directories, 1)
            positive_image = imread([positive_directories(j, :) filesep sprintf('%d.jpg', c)]);
            
            if rotate_images == 1 && rand > 0.5
                positive_image = imrotate(positive_image, 180);
            end;
            
            test_set(:, index) = positive_image(:);
            labels(index) = j;
            index = index + 1;
        end;
    end;

    % Load empty negative images
    fprintf('Loading %d empty negative images.\n', NUM_EMPTY_NEG);
    random_vector = randperm(2000, NUM_EMPTY_NEG);
    for j=1:length(random_vector)
        negative_image = imread(['empty_train' filesep sprintf('%d.jpg', random_vector(j))]);
        test_set(:, index) = negative_image(:);
        index = index + 1;
    end;
    
    % Load general negative images
    fprintf('Loading %d general negative images.\n', NUM_GENERAL_NEG);
    random_vector = randperm(2000, NUM_GENERAL_NEG);
    for j=1:length(random_vector)
        negative_image = imread(['back_train' filesep sprintf('%d.jpg', random_vector(j))]);
        test_set(:, index) = negative_image(:);
        index = index + 1;
    end;

end

