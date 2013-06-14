% Loads all the data
%

clear all;

disp('Loading training_set for 10.');
[training_10_set, labels_10] = load_training(10);

disp('Loading training_set for 98');
[training_98_set, labels_98] = load_training(98);

disp('Loading training_set for 16.');
[training_16_set, labels_16] = load_training(16);

disp('Loading training_set for 37.');
[training_37_set, labels_37] = load_training(37);

disp('Loading test_set.');
[test_set, test_labels] = load_test(0);