%
% Demo SIFT
% Demostrates SIFT on a couple of test images
%
%

% The number for each class in the reference set
NUM_REF = 10;

X_BINS = [120 240 360];
Y_BINS = [160 320 480];
ROTATION_BINS = [30 60 90 120 150 180 210 240 270 300 330];
SCALE_BINS = [2 4 8 16 32];
NUM_X_BINS = length(X_BINS) + 1;
NUM_Y_BINS = length(Y_BINS) + 1;
NUM_ROTATION_BINS = length(ROTATION_BINS) + 1;
NUM_SCALE_BINS = length(SCALE_BINS) + 1;

positives_training_10_set = training_10_set(:,labels_10 > 0);
positives_training_98_set = training_98_set(:,labels_98 > 0);

selected_training = randperm(size(positives_training_10_set, 2) - 1, NUM_REF) + 1;
positives_training_10_set = positives_training_10_set(:, selected_training);
positives_training_98_set = positives_training_98_set(:, selected_training);

test_image = training_10_set(:, 1);

% Compute Hough Table for 10
% First dimension is x
% Second dimension is y
% Third dimension is scale
% Fourth dimension is rotation
hough_table_10 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
[test_f, test_d] = vl_sift(im2single(reshape(test_image, [480 640])));
for i=1:size(positives_training_10_set, 2)
    [refer_f, refer_d] = vl_sift(im2single(reshape(positives_training_10_set(:, i), [480 640])));
    [matches, scores] = vl_ubcmatch(test_d, refer_d);
    
    test_frame = test_f(:, matches(1, :));
    ref_frame = refer_f(:, matches(2, :));
    
    to_bin = zeros(size(test_frame));
    
    to_bin(3, :) = test_frame(3,:) ./ ref_frame(3, :);
    
    % Translate reference frame
    ref_frame(1, :) = ref_frame(1, :) - 320;
    ref_frame(2, :) = ref_frame(2, :) - 240;
    
    % Rescale reference frame
    ref_frame(1:2, :) = ref_frame(1:2, :) .* repmat(to_bin(3, :), 2, 1);
        
    % Translate frame back
    ref_frame(1, :) = ref_frame(1, :) + 320;
    ref_frame(2, :) = ref_frame(2, :) + 240;
    
    % Setup x and y translation
    to_bin(1:2, :) = test_frame(1:2, :) - ref_frame(1:2, :);
    to_bin(1,:) = to_bin(1,:) + 320;
    to_bin(2,:) = to_bin(2,:) + 240;

    to_bin(4, :) = mod(radtodeg(test_frame(4, :) - ref_frame(4, :)) + 360, 360);
    
    x_index = vl_binsearch(X_BINS, to_bin(1, :)) + 1;
    y_index = vl_binsearch(Y_BINS, to_bin(2, :)) + 1;
    scale_index = vl_binsearch(SCALE_BINS, to_bin(3, :)) + 1;
    rot_index = vl_binsearch(ROTATION_BINS, to_bin(4, :)) + 1;
    
    for i=1:length(x_index)
        x_indexes = shift_bining([x_index(i)-1 x_index(i) x_index(i)+1], NUM_X_BINS);
        y_indexes = shift_bining([y_index(i)-1 y_index(i) y_index(i)+1], NUM_Y_BINS);
        scale_indexes = shift_bining([scale_index(i)-1 scale_index(i) scale_index(i)+1], NUM_SCALE_BINS);
        rot_indexes = shift_bining([rot_index(i)-1 rot_index(i) rot_index(i)+1], NUM_ROTATION_BINS);
        hough_table_10(x_indexes, y_indexes, scale_indexes, rot_indexes) = hough_table_10(x_indexes, y_indexes, scale_indexes, rot_indexes) + 1;
    end;
    
end;


hough_table_98 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
[test_f, test_d] = vl_sift(im2single(reshape(test_image, [480 640])));
for i=1:size(positives_training_98_set, 2)
    [refer_f, refer_d] = vl_sift(im2single(reshape(positives_training_98_set(:, i), [480 640])));
    [matches, scores] = vl_ubcmatch(test_d, refer_d);
    
    test_frame = test_f(:, matches(1, :));
    ref_frame = refer_f(:, matches(2, :));
    
    to_bin = zeros(size(test_frame));
    
    to_bin(3, :) = test_frame(3,:) ./ ref_frame(3, :);
    
    % Translate reference frame
    ref_frame(1, :) = ref_frame(1, :) - 320;
    ref_frame(2, :) = ref_frame(2, :) - 240;
    
    % Rescale reference frame
    ref_frame(1:2, :) = ref_frame(1:2, :) .* repmat(to_bin(3, :), 2, 1);
        
    % Translate frame back
    ref_frame(1, :) = ref_frame(1, :) + 320;
    ref_frame(2, :) = ref_frame(2, :) + 240;
    
    % Setup x and y translation
    to_bin(1:2, :) = test_frame(1:2, :) - ref_frame(1:2, :);
    to_bin(1,:) = to_bin(1,:) + 320;
    to_bin(2,:) = to_bin(2,:) + 240;

    to_bin(4, :) = mod(radtodeg(test_frame(4, :) - ref_frame(4, :)) + 360, 360);
    
    x_index = vl_binsearch(X_BINS, to_bin(1, :)) + 1;
    y_index = vl_binsearch(Y_BINS, to_bin(2, :)) + 1;
    scale_index = vl_binsearch(SCALE_BINS, to_bin(3, :)) + 1;
    rot_index = vl_binsearch(ROTATION_BINS, to_bin(4, :)) + 1;
    
    for i=1:length(x_index)
        x_indexes = shift_bining([x_index(i)-1 x_index(i) x_index(i)+1], NUM_X_BINS);
        y_indexes = shift_bining([y_index(i)-1 y_index(i) y_index(i)+1], NUM_Y_BINS);
        scale_indexes = shift_bining([scale_index(i)-1 scale_index(i) scale_index(i)+1], NUM_SCALE_BINS);
        rot_indexes = shift_bining([rot_index(i)-1 rot_index(i) rot_index(i)+1], NUM_ROTATION_BINS);
        hough_table_98(x_indexes, y_indexes, scale_indexes, rot_indexes) = hough_table_98(x_indexes, y_indexes, scale_indexes, rot_indexes) + 1;
    end;
    
end;
