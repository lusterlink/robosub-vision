function [ ] = hough_table_plot(hough_table, X_BINS, Y_BINS, SCALE_BINS, ROTATION_BINS)

    [max_count, position] = max(hough_table(:));
    
    [~,~,scale_index,~] = ind2sub(size(hough_table), position);

    hough_table = hough_table(:,:,scale_index, :);
    
    total_num_vectors = numel(hough_table);
    
    X = zeros(total_num_vectors, 1);
    Y = zeros(total_num_vectors, 1);
    U = zeros(total_num_vectors, 1);
    V = zeros(total_num_vectors, 1);
    
    X_BINS = ([X_BINS 640] + [0 X_BINS]) ./ 2;
    Y_BINS = ([Y_BINS 480] + [0 Y_BINS]) ./ 2;
    SCALE_BINS = ([SCALE_BINS 64] + [0 SCALE_BINS]) ./ 2;
    ROTATION_BINS = ([ROTATION_BINS 360] + [0 ROTATION_BINS]) ./ 2;
    
    index = 1;
    for x=1:size(hough_table, 1)
        for y=1:size(hough_table, 2)
            for rot=1:size(hough_table, 4)
                X(index) = X_BINS(x);   
                Y(index) = Y_BINS(y);
                rotation = degtorad(ROTATION_BINS(rot));
                
                mag = hough_table(x,y,1,rot) / max_count;
                
                U(index) = cos(rotation) * mag;
                V(index) = sin(rotation) * mag;
            
                index = index + 1;
            end;
        end;
    end;

    figure(1); clf; quiver(X, Y, U, V);
    
    
end

