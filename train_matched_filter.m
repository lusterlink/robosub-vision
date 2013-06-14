function [ matched_filter ] = train_matched_filter( images )
%train_matched_filter Trains a matched filter from the given images
%   Computes the average of the images to make a matched filter
    matched_filter = mean(images, 2);
end

