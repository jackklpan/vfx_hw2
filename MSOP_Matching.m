function [ output_args ] = MSOP_Matching( a, b )
% extract feature of a
[aFP, aD, aD_vec, aC] = MSOP_Feature(a);
aC_arr = [aC{:}]';

% extract feature of b
[bFP,bD,bD_vec, bC] = MSOP_Feature(b);
bC_arr = [bC{:}]';

% use HaarWT Coeficient find KNN
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

matched = (first_err < 0.65 * err_outlier);


right = bFP(matched);
left = aFP(first_NN(matched));

% draw two pic & matched feature
figure
imshow([a b]);
hold on;
for i =1: length(right)
    str = [' ' num2str(i)];
    text(right(i).x+size(a,2), right(i).y, str);
    plot (right(i).x+size(a,2), right(i).y, 'rx');
    
    text(left(i).x, left(i).y, str);
    plot (left(i).x, left(i).y, 'bx');
end

end

