function [ values ] = classify_matched_filter( images, filter )
%classify_matched_filter Classifies a given image using the provided
%matched filter and threshhold
%   Uses cross-correlation to determine the how closely the image matches
%   the given filter and uses the threshhold to make the classification
NUM_POS = 1000;
NUM_EMPTY_NEG = 1100;
NUM_GENERAL_NEG = 1000;
NUM_OTHER_NEG = 900;
NUM_OVERALL = NUM_POS + NUM_EMPTY_NEG + NUM_GENERAL_NEG + NUM_OTHER_NEG;
values = zeros(1, NUM_OVERALL);
for i=1:NUM_OVERALL
    % values(i) = max(xcorr(double(images(:, i)), filter, 'coeff'));
    temp = reshape(images(:, i), 480, 640);
    values(i) = max(max(xcorr2(temp(50:400, 150:520), filter)));
    disp(i);
end
end

