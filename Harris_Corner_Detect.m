function feat_points = Harris_Corner_Detect (input, th)
%% parameters
% gaussian
gw = 5; sigma = 1.0;
% Response value
k = 0.06;
    
% get Y of input_image -> img
channel_num = size (input, 3);
if channel_num == 3
	input_yiq = rgb2ntsc (input);
	img = input_yiq(:, :, 1);
elseif channel_num == 1
	img = input;
end

%%  Calculate Response Value -> R(i, j)
w = fspecial ('gaussian', [gw gw], sigma);
[Ix, Iy] = imgradientxy (img);
wIx2 = conv2 (Ix .^ 2, w, 'same');
wIy2 = conv2 (Iy .^ 2, w, 'same');
wIxIy = conv2 (Ix .* Iy, w, 'same');

% construct M{i, j}
for i = 1: size (img, 1)
	for j = 1: size (img, 2)
		M{i, j} = [	wIx2(i, j)	wIxIy(i, j); ...
						wIxIy(i, j)	wIy2(i, j)];
	end
end

% calculate R(i, j)
for i = 1: size(img, 1)
	for j = 1: size(img, 2)
		R(i, j) = det (M{i, j}) - k * trace (M{i, j})^2;
	end
end

% find features
feat_points = (R > th) & local_max(R);

imshow(img);
hold on;
[f_y, f_x] =find (feat_points == 1);
plot (f_x, f_y, 'ro');
hold off;

end

function pks = local_max (arr)

pks = zeros(size (arr, 1), size (arr, 2));

for i = 2: size(arr, 1) - 1
    for j = 2: size(arr, 2) - 1
        cnt = 0;
        for u = -1: 1
            for v = -1:1
                if arr(i, j) > arr(i+u, j+v)
                    cnt = cnt + 1;
                end
            end
        end
        if cnt == 8
            pks(i, j) = 1;
        end
    end
end

end