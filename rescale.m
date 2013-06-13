function [ output ] = rescale(x, scale)
%rescale Rescale input vector for scale

unit = x ./ norm(x);
new_mag = norm(x) * scale;
output = unit .* new_mag;

end

