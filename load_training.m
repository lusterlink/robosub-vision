function [ training_set, labels ] = load_training( number )
%load_training Loads the specified training set
%   Loads the specified training set, either 98, 37, 16, or 10 set
%   The training set has 1000 positive images and 4000 negatives
%   from both the background empty ones and the other training sets.
%
%   Each image is a column in the training_set matrix


    NUM_POS = 1000;
    NUM_EMPTY_NEG = 1100;
    NUM_GENERAL_NEG = 1000;
    NUM_OTHER_NEG = 900;
    NUM_OVERALL = NUM_POS + NUM_EMPTY_NEG + NUM_GENERAL_NEG + NUM_OTHER_NEG;

    if number ~= 10 && number ~= 16 && number ~= 37 && number ~= 98
        disp(['Unable to find corresponding training set: ' number]);
    end;
    
    possible = [10 16 37 98];
    possible = possible(possible~=number);
    
    positive_directory = [sprintf('%d_train', number) filesep];
    training_set = zeros(640*480, NUM_OVERALL, 'uint8');
    labels = -1 * ones(NUM_OVERALL, 1, 'int8');
    labels(1:NUM_POS) = ones(NUM_POS, 1);
    
    % Load positive images
    fprintf('Loading %d positive images.\n', NUM_POS);
    for i=1:NUM_POS
        positive_image = imread([positive_directory sprintf('%d.jpg', i)]);
        training_set(:,i) = positive_image(:);
    end;
    
    % Load negative images, 1100 from empty background, 1000 from general
    % and 900 from other training_sets
    random_vector = randperm(2000, NUM_EMPTY_NEG);
    fprintf('Loading %d empty negatives.\n', NUM_EMPTY_NEG);
    for j=1:length(random_vector)
        negative_image = imread(['empty_train' filesep sprintf('%d.jpg', random_vector(j))]);
        training_set(:,NUM_POS+j) = negative_image(:);
    end;
    
    fprintf('Loading %d general negatives.\n', NUM_GENERAL_NEG);
    random_vector = randperm(2000, NUM_GENERAL_NEG);
    for j=1:length(random_vector)
        negative_image = imread(['back_train' filesep sprintf('%d.jpg', random_vector(j))]);
        training_set(:,NUM_POS+NUM_EMPTY_NEG+j) = negative_image(:);
    end;
    
    random_vector = randperm(1000, NUM_OTHER_NEG/3);
    k = 1;
    fprintf('Loading %d other negatives.\n', NUM_OTHER_NEG);
    for j=1:length(random_vector)
        for i=1:length(possible)
            negative_image = imread([sprintf('%d_train', possible(i)) filesep sprintf('%d.jpg', random_vector(j))]);
            training_set(:,NUM_POS+NUM_EMPTY_NEG+NUM_GENERAL_NEG+k) = negative_image(:);
            k = k + 1;
        end;
    end;

end

