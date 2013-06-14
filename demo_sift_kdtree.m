%
% Demo SIFT
% Demostrates SIFT on a couple of test images
% Requires running of init, load_all_data, build_kdtrees
%

% The binning for the HOUGE TABLES
%Y_BINS = [120 240 360];
Y_BINS = linspace(20, 460, 20);
%X_BINS = [160 320 480];
X_BINS = linspace(20, 620, 20);
ROTATION_BINS = [30 60 90 120 150 180 210 240 270 300 330];
SCALE_BINS = [2 4 8 16 32];
NUM_X_BINS = length(X_BINS) + 1;
NUM_Y_BINS = length(Y_BINS) + 1;
NUM_ROTATION_BINS = length(ROTATION_BINS) + 1;
NUM_SCALE_BINS = length(SCALE_BINS) + 1;

% Probablity of certainity needed for classification
PROB_NEEDED = 0.1;

% First dimension is x
% Second dimension is y
% Third dimension is scale
% Fourth dimension is rotation
hough_table_10 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_98 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_37 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_16 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);

order = ['10'; '98'; '37'; '16'];

total_hits = 0;
total_misses = 0;
offset = 75;

for test_num=1:size(test_set, 2)
    fprintf('Performing classification on image#%d/%d.\n', test_num, size(test_set, 2));

%    test_image = test_set(:, test_num);
  %  test_image = test_set(:, offset+test_num);
    test_image = training_10_set(:, 1);
    [test_f, test_d] = vl_sift(im2single(reshape(test_image, [480 640])));

    for current=1:length(order)

        if current == 1
            overall_d = overall_d_10;
            overall_f = overall_f_10;
            forest = forest_10;
            hough_table = hough_table_10;
        elseif current == 2
            overall_d = overall_d_98;
            overall_f = overall_f_98;
            forest = forest_98;
            hough_table = hough_table_98;
        elseif current == 3
            overall_d = overall_d_37;
            overall_f = overall_f_37;
            forest = forest_37;
            hough_table = hough_table_37;
        elseif current == 4
            overall_d = overall_d_16;
            overall_f = overall_f_16;
            forest = forest_16;
            hough_table = hough_table_16;
        else
            disp('Fell through on current states.');
            pause
        end;

        fprintf('Starting generation for hough table for %s set.\n', order(current,:));
        
        [neighbor_indexes, neighbor_distances] = vl_kdtreequery(forest, overall_d, single(test_d), 'NUMNEIGHBORS', 2);
        
        % Filter out the ones that we cannot discern
        neighbor_indexes = neighbor_indexes((neighbor_distances(1,:) ./ neighbor_distances(2,:)) < 0.8);
        neighbor_indexes = neighbor_indexes(1, :);
                
        % Select the ones we are interested in
        test_frame = test_f(:, (neighbor_distances(1,:) ./ neighbor_distances(2,:)) < 0.8);
        ref_frame = overall_f(:, neighbor_indexes);

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
        
        fprintf('We have a length of %d.\n', length(x_index));

        for i=1:length(x_index)
            x_indexes = shift_bining([x_index(i)-1 x_index(i) x_index(i)+1], NUM_X_BINS);
            y_indexes = shift_bining([y_index(i)-1 y_index(i) y_index(i)+1], NUM_Y_BINS);
            scale_indexes = shift_bining([scale_index(i)-1 scale_index(i) scale_index(i)+1], NUM_SCALE_BINS);
            rot_indexes = shift_bining([rot_index(i)-1 rot_index(i) rot_index(i)+1], NUM_ROTATION_BINS);
            hough_table(x_indexes, y_indexes, scale_indexes, rot_indexes) = hough_table(x_indexes, y_indexes, scale_indexes, rot_indexes) + 1;
        end;

        fprintf('Saving back to hough tables for %s\n', order(current,:));
        if current == 1
            hough_table_10 = hough_table;
        elseif current == 2
            hough_table_98 = hough_table;
        elseif current == 3
            hough_table_37 = hough_table;
        elseif current == 4
            hough_table_16 = hough_table;
        else
            disp('Fell through on current states.');
            pause
        end;

    end;


    % Perform classification
    max_10 = max(hough_table_10(:));
    max_98 = max(hough_table_98(:));
    max_37 = max(hough_table_37(:));
    max_16 = max(hough_table_16(:));

    maxes = [max_10; max_98; max_37; max_16];
    max_count = max(maxes);
    maxes = sort(maxes, 'descend');
    classification = -1;

    if (maxes(1) - maxes(2))/(maxes(1)) < PROB_NEEDED
        disp('No decision');
    elseif max_count == max_10
        disp('Classifying as 10');
        hough_table = hough_table_10;
        classification = 4;
    elseif max_count == max_16
        disp('Classifying as 16')
        hough_table = hough_table_16;
        classification = 3;
    elseif max_count == max_98
        disp('Classifying as 98')
        hough_table = hough_table_98;
        classification = 1;
    elseif max_count == max_37
        disp('Classifying as 37')
        hough_table = hough_table_37;
        classification = 2;
    else
        disp('Fell through on states')
    end;
    
    
    if classification == test_labels(test_num+offset);
        total_hits = total_hits + 1;
        disp('HIT!!!!');
    else
        disp('MISS!!!!!');
    end;
    
    pause();
end;
