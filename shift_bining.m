function [ output ] = shift_bining( indexes, maxi )
%shift_binning Shifts the indexes to make sure we don't go out of bounds

output = indexes;
if max(indexes) > maxi
    output = output - 1;
elseif min(indexes) < 1
    output = output + 1;
end;

end

