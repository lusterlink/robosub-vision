classes = [10];

filter = load('filter.mat');

filters = {filter.filter_10, filter.filter_98, filter.filter_37, filter.filter_16};
for ci=1:length(classes),
    class = classes(ci);
    imgs = load_training(class);
    disp('starting 10 classifier')
    vals_10 = batch('classify_matched_filter', 1, {imgs, filters{1}});
    disp('starting 98 classifier')
    vals_98 = batch('classify_matched_filter', 1, {imgs, filters{2}});
    disp('starting 37 classifier')
    vals_37 = batch('classify_matched_filter', 1, {imgs, filters{3}});
    disp('starting 16 classifier')
    vals_16 = batch('classify_matched_filter', 1, {imgs, filters{4}});
    disp('Finished round')
    disp(ci)
end