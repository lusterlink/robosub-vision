% This scripts builds the kd trees for the sift


% The number for each class in the reference set
NUM_REF = 200;

positives_training_10_set = training_10_set(:,labels_10 > 0);
positives_training_98_set = training_98_set(:,labels_98 > 0);
positives_training_37_set = training_37_set(:,labels_37 > 0);
positives_training_16_set = training_16_set(:,labels_16 > 0);

selected_training = randperm(size(positives_training_10_set, 2) - 1, NUM_REF) + 1;
positives_training_10_set = positives_training_10_set(:, selected_training);
positives_training_98_set = positives_training_98_set(:, selected_training);
positives_training_37_set = positives_training_37_set(:, selected_training);
positives_training_16_set = positives_training_16_set(:, selected_training);

% Build the KD trees
disp('Starting kd tree building.');

overall_d_10 = [];
overall_f_10 = [];

overall_d_98 = [];
overall_f_98 = [];
        
overall_d_37 = [];
overall_f_37 = [];
        
overall_d_16 = [];
overall_f_16 = [];
        

for i=1:size(positives_training_10_set, 2)
    
    if mod(i, 1) == 0
        fprintf('Currently building kdtree iteration %d.\n', i);
    end;
    
    [refer_f_10, refer_d_10] = vl_sift(im2single(reshape(positives_training_10_set(:, i), [480 640])));
    overall_f_10 = [overall_f_10 refer_f_10];
    overall_d_10 = [overall_d_10 single(refer_d_10)];
    
    [refer_f_98, refer_d_98] = vl_sift(im2single(reshape(positives_training_98_set(:, i), [480 640])));
    overall_f_98 = [overall_f_98 refer_f_98];
    overall_d_98 = [overall_d_98 single(refer_d_98)];
    
    [refer_f_37, refer_d_37] = vl_sift(im2single(reshape(positives_training_37_set(:, i), [480 640])));
    overall_f_37 = [overall_f_37 refer_f_37];
    overall_d_37 = [overall_d_37 single(refer_d_37)];
    
    [refer_f_16, refer_d_16] = vl_sift(im2single(reshape(positives_training_16_set(:, i), [480 640])));
    overall_f_16 = [overall_f_16 refer_f_16];
    overall_d_16 = [overall_d_16 single(refer_d_16)];
    
end;
        
forest_10 = vl_kdtreebuild(overall_d_10);
forest_16 = vl_kdtreebuild(overall_d_16);
forest_98 = vl_kdtreebuild(overall_d_98);
forest_37 = vl_kdtreebuild(overall_d_37);

        
disp('Ending kd tree building.');