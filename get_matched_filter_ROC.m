function [ ROC_rates, PRC_rates ] = get_matched_filter_ROC( values, class )
%get_matched_filter_ROC Returns the [falsePosRate, truePosRate]
%   Gets the data to plot an ROC for a matched filter

values = (sortrows(values', 1))';

curr_true_pos = 1000;
curr_false_pos = 3000;
ROC_rates = zeros(4002, 2);
ROC_rates(1, :) = [1 1];

PRC_rates = zeros(4002, 2);
% [precision, recall]
PRC_rates(1, :) = [curr_true_pos / max(eps, curr_true_pos + curr_false_pos), 1];
for i=1:length(values)
    curr_val = values(:, i);
    if (curr_val(2, 1) == class)
        curr_true_pos = curr_true_pos - 1;
    else
        curr_false_pos = curr_false_pos - 1;
    end
    % Precision
    PRC_rates(i+1, 1) = curr_true_pos / max(eps, curr_true_pos + curr_false_pos);
    
    % False positive rate
    ROC_rates(i+1, 1) = curr_false_pos / 3000;
    % True positive rate or recall
    ROC_rates(i+1, 2) = curr_true_pos / 1000;
    PRC_rates(i+1, 2) = curr_true_pos / 1000;
end

ROC_rates(4002, :) = [0 0];
PRC_rates(4002, :) = [0 0];

% ROC_rates(ROC_rates(:, 2) < 0.5, 2) = 1 - ROC_rates(ROC_rates(:, 2) < 0.5, 2)

end

