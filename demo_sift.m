%
% Demo SIFT
% Demostrates SIFT on a couple of test images
%
%

% The number for each class in the reference set
NUM_REF = 100;

% The binning for the HOUGE TABLES
Y_BINS = [120 240 360];
%Y_BINS = linspace(20, 460, 40);
X_BINS = [160 320 480];
%X_BINS = linspace(20, 620, 40);
ROTATION_BINS = [30 60 90 120 150 180 210 240 270 300 330];
SCALE_BINS = [2 4 8 16 32];
NUM_X_BINS = length(X_BINS) + 1;
NUM_Y_BINS = length(Y_BINS) + 1;
NUM_ROTATION_BINS = length(ROTATION_BINS) + 1;
NUM_SCALE_BINS = length(SCALE_BINS) + 1;

% Probablity of uncertainity needed for classification
PROB_NEEDED = 0.05;

positives_training_10_set = training_10_set(:,labels_10 > 0);
positives_training_98_set = training_98_set(:,labels_98 > 0);
positives_training_37_set = training_37_set(:,labels_37 > 0);
positives_training_16_set = training_16_set(:,labels_16 > 0);

% First dimension is x
% Second dimension is y
% Third dimension is scale
% Fourth dimension is rotation
hough_table_10 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_98 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_37 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);
hough_table_16 = zeros(NUM_X_BINS, NUM_Y_BINS, NUM_SCALE_BINS, NUM_ROTATION_BINS);

order = ['10'; '98'; '37'; '16'];

selected_training = randperm(size(positives_training_10_set, 2) - 1, NUM_REF) + 1;
positives_training_10_set = positives_training_10_set(:, selected_training);
positives_training_98_set = positives_training_98_set(:, selected_training);
positives_training_37_set = positives_training_37_set(:, selected_training);
positives_training_16_set = positives_training_16_set(:, selected_training);


total_hits = 0;
total_misses = 0;
confusion_matrix = zeros(5, 5);
offset = 80;

for test_num=1:size(test_set, 2)
    fprintf('Performing classification on image#%d/%d.\n', test_num+offset, size(test_set, 2));

%    test_image = test_set(:, test_num);
    test_image = test_set(:, offset+test_num);
   % test_image = positives_training_37_set(:, 16+test_num);
    [test_f, test_d] = vl_sift(im2single(reshape(test_image, [480 640])));

    for current=1:length(order)

        if current == 1
            training_set = positives_training_10_set;
            hough_table = hough_table_10;
        elseif current == 2
            training_set = positives_training_98_set;
            hough_table = hough_table_98;
        elseif current == 3
            training_set = positives_training_37_set;
            hough_table = hough_table_37;
        elseif current == 4
            training_set = positives_training_16_set;
            hough_table = hough_table_16;
        else
            disp('Fell through on current states.');
            pause
        end;

        fprintf('Starting generation for hough table for %s set.\n', order(current,:));
        for i=1:size(training_set, 2)
            if mod(i, 10) == 0
                fprintf('Generating corresponding for image #%d.\n', i);
            end;
            % We don't mind doing this every step because this saves us
            % overall memory, and this step is really fast
            % The reason why we don't just call this once is talked about
            % in the write up
            [refer_f, refer_d] = vl_sift(im2single(reshape(training_set(:, i), [480 640])));
            
            % This is the slow step that utilizes a KD tree to find
            % matches that satisy the threshold defined in the writeup
            [matches, scores] = vl_ubcmatch(test_d, refer_d);

            % Select survivors
            test_frame = test_f(:, matches(1, :));
            ref_frame = refer_f(:, matches(2, :));

            to_bin = zeros(size(test_frame));

            % Compute scale
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

            % Compute rotation 
            to_bin(4, :) = mod(radtodeg(test_frame(4, :) - ref_frame(4, :)) + 360, 360);

            % Now perform binning
            x_index = vl_binsearch(X_BINS, to_bin(1, :)) + 1;
            y_index = vl_binsearch(Y_BINS, to_bin(2, :)) + 1;
            scale_index = vl_binsearch(SCALE_BINS, to_bin(3, :)) + 1;
            rot_index = vl_binsearch(ROTATION_BINS, to_bin(4, :)) + 1;

            % Place into hough table
            for i=1:length(x_index)
                x_indexes = shift_bining([x_index(i)-1 x_index(i) x_index(i)+1], NUM_X_BINS);
                y_indexes = shift_bining([y_index(i)-1 y_index(i) y_index(i)+1], NUM_Y_BINS);
                scale_indexes = shift_bining([scale_index(i)-1 scale_index(i) scale_index(i)+1], NUM_SCALE_BINS);
                rot_indexes = shift_bining([rot_index(i)-1 rot_index(i) rot_index(i)+1], NUM_ROTATION_BINS);
                hough_table(x_indexes, y_indexes, scale_indexes, rot_indexes) = hough_table(x_indexes, y_indexes, scale_indexes, rot_indexes) + 1;
            end;

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

    % Determine how confident we are
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
    
    row = test_labels(test_num+offset) + 1;
    if row == 0
        row = row + 1;
    end;
    classification = classification + 1;
    if classification == 0
        classification = classification + 1;
    end;
    
    confusion_matrix(row, classification) = confusion_matrix(row, classification) + 1;
    
end;
