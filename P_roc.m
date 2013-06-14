function [ P, OP, A, T ] = roc ( X, GoodToBad, xAxis, linewidth, fontsize, linecolor, plot_flag )

%
%  function [ P, OP, T ] = roc ( X, GoodToBad, xAxis )
%
%  drawROC plots an ROC curve
%
%  Input data:
%
%  	X	N x 2	The first column contains the score, the second column contains 
%			the labels. There are 2 labels. The smaller label is considered
%			`noise' the larger one is considered `signal'
%
%  GoodToBad	scalar 	Allows to rescale the ratio of signal and noise samples. 
%			Just put 1 here if you're not sure.
%
%  xAxis	2 x 1	The range for the x-axis. This allows to close in or zoom out. 
%			Put [0 1] if you are not sure.
%

%
%  (c) 1997 by California Institute of Technology
% 
%  Markus Weber
%
%  $Log: roc.m,v $
%  Revision 1.1.1.1  2002/11/21 19:01:47  fergus
%  Inital import of constellation model code
%
%  Revision 1.4  1999/11/11 16:56:43  mweber
%  Added operation point and area computation.
%
%  Revision 1.3  1999/09/26 20:51:11  mweber
%  Changed return arguments.
%
%  Revision 1.2  1999/05/08 04:32:38  mweber
%  Clean-up
%
%  30 March 2005 - P. Perona
%% Added default arguments 2 and 3
%% Modified meaning of labels - noise is not nec. 0 but the smaller of the
%% two labels now.

if nargin < 2, GoodToBad=1; end;

if nargin<3, xAxis=[0; 1]; end;

if nargin < 4
	linewidth = 1;
end

if nargin < 5
	fontsize = 10;
end

if nargin < 6,
    linecolor = 'r-';
end;

if nargin < 7,
    plot_flag = 1;
end;

noise_label = min(X(:,2)); 
N_SAMPLES = size(X, 1);
N_SIGNAL  = length(find(X(:, 2)));
N_NOISE   = N_SAMPLES - N_SIGNAL;


[D, I] = sort(rand(N_SAMPLES, 1));

X = X(I, :);

[D, I] = sort(X(:, 1));

X = round(flipud(X(I, :))*1000000)/1000000;

Q=[ (X(:, 2) > 0) / N_SIGNAL, (X(:, 2) == 0) / N_NOISE ];

%%%% COMPLEX BIT TO SORT OUT PROBLEMS WITH SAME LH VALUES FOR LOTS OF
%FRAMES - only works for two-class ROC curves

XX = unique(X(:,1));

for a=1:length(XX)
   
   X_Same=find(X(:,1)==XX(a));
   
   X_Same_Pos=find(X(X_Same,2));
   X_Same_Neg=find(~X(X_Same,2));

   if (length(X_Same_Pos>0) & length(X_Same_Neg>0)) %% now we have a mix of frames at
                                        %the same LH value and a
                                        %problem.....
	
	Q(X_Same,:)=repmat(sum(Q(X_Same,:),1)/size(X_Same,1),size(X_Same,1),1);;
	%Q(X_Same(2:end),:)=zeros(size(X_Same,1)-1,2);
	
   end
   
end

P = cumsum(Q);
%P = cumsum([ (X(:, 2) > 0) / N_SIGNAL, (X(:, 2) == 0) / N_NOISE ]);

if plot_flag,
plot(P(:, 2) * 1/GoodToBad, P(:, 1), linecolor, 'LineWidth', linewidth); grid;

set(gca, 'xtick', xAxis(1):(xAxis(2) - xAxis(1)) / 10:xAxis(2), 'ytick', 0:0.1:1);

axis ([xAxis(:)', 0 1 ]);
axis('square');

xlabel('P_{fa}');
ylabel('P_{d}');
end;

% Compute area under curve

%keyboard

noiseIdx = find(~X(:, 2));

A = sum(P(noiseIdx, 1)) / N_NOISE;

P = fliplr(P);

% Find intersection point with diagonal

[dum idx] = min(abs(P(:, 1) - (1 - P(:, 2))));

OP = P(idx, 2);

T = 0.5 * (X(idx, 1) + X(max(1, idx + 1), 1));






