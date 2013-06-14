num_true_pos = 1000;
num_false_pos = 3000;

curr_true_pos = 1000;
curr_false_pos = 3000;
rates = zeros(4002, 2);
rates(1, :) = [curr_true_pos / max(eps, curr_true_pos + curr_false_pos) 1];
for i=1:length(t)
    curr_val = t(:, i);
    if (curr_val(2, 1) == 10)
        curr_true_pos = curr_true_pos - 1;
    else
        curr_false_pos = curr_false_pos - 1;
    end
    % False positive rate
    rates(i+1, 1) = curr_false_pos / 3000;
    % True positive rate
    rates(i+1, 2) = curr_true_pos / 1000;
end

rates(4002, :) = [0 0];