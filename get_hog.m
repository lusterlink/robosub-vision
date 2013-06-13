function [ H ] = get_hog( image )
%get_hog Computes hog for input image
%   Utilizes Piot's functions
    image = im2single(image);
    
    H = hog(image, 8, 9);
end

