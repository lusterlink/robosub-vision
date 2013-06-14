%
% Plot some targets
%

[maxi, position] = max(hough_table(:));
[x,y,s,o] = ind2sub(size(hough_table), position);

X_VAL_BINS = ([X_BINS 640] + [0 X_BINS]) ./ 2;
Y_VAL_BINS = ([Y_BINS 480] + [0 Y_BINS]) ./ 2;
SCALE_VAL_BINS = ([SCALE_BINS 64] + [0 SCALE_BINS]) ./ 2;
ROTATION_VAL_BINS = ([ROTATION_BINS 360] + [0 ROTATION_BINS]) ./ 2;

x = X_VAL_BINS(x);
y = Y_VAL_BINS(y);
scale_val = SCALE_VAL_BINS(s);

length_l = 600 * scale_val;
width = 400 * scale_val;

figure(1); clf;
imshow(reshape(test_image, [480 640]));
line([x-length_l/2 x+length_l/2], [y y], 'Color', 'g');
line([x x], [y-width/2 y+width/2], 'Color', 'g');
rectangle('Position', [x-length_l/2, y-width/2, length_l, width], 'EdgeColor', 'r');