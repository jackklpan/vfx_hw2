function [ aFP_position, bFP_position ] = MSOP_Matching( a, b )
% extract feature of a
[aFP, aD, aD_vec, aC] = MSOP_Feature(a);
% extract feature of b
[bFP,bD,bD_vec, bC] = MSOP_Feature(b);

%% parameter
% outlier ratio
outlier_ratio = 0.23;

%% start matching
% use HaarWT Coeficient find KNN
aC_arr = [aC{:}]';
bC_arr = [bC{:}]';
[Approx_IDX, D] = knnsearch(aC_arr, bC_arr, 'K', 10, 'NSMethod', 'kdtree');

% use Descriptor find BestNN from KNN
for i = 1: length(bFP)
    list = Approx_IDX(i, :);
    aD_vec_arr = [aD_vec{list}]';
    [final_IDX, final_D] = knnsearch(aD_vec_arr, bD_vec{i}', 'K', 2, 'NSMethod', 'exhaustive');
    first_NN(i) = list(final_IDX(1));
    first_err(i) = final_D(1);
    sec_err(i) = final_D(2);
end

% err_outlier = average of err_2ndNN 
err_outlier = sum(sec_err(:)) / length(sec_err);

matched = (first_err < outlier_ratio * err_outlier);


right = bFP(matched);
left = aFP(first_NN(matched));

%% output
bFP_position = [right.x; right.y]';
aFP_position = [left.x; left.y]';

%% draw two pic & matched feature

figure
imshow([a b]);
hold on;
for i =1: length(right)
    RF = [right(i).x+size(a,2), right(i).y];
    LF = [left(i).x, left(i).y];
    
    %str = [' ' num2str(i)];
    %text(right(i).x+size(a,2), right(i).y, str);
    %text(left(i).x, left(i).y, str);

    line ([LF(1) RF(1)], [LF(2) RF(2)], 'color', [0 1 0]);
    
    plot (RF(1), RF(2), 'r<');
    plot (LF(1), LF(2), 'b>');
end
%}
end

