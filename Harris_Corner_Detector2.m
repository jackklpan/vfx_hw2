function fp_loc = Harris_Corner_Detector2 (input)
%% parameters
% gaussian-- d:blur, i:window
gw_d = 5;   sig_d = 1/1.414;
gw_i = 7;   sig_i = 1.5/1.414;
% threshold
th = 0.1;

% get Y of input_image -> img
channel_num = size (input, 3);
if channel_num == 3
	input_yiq = rgb2ntsc (input);
	img = input_yiq(:, :, 1);
elseif channel_num == 1
	img = input;
end

%%  Calculate Response function -> f_hm(i, j)
blur = fspecial ('gaussian', [gw_d gw_d], sig_d);
%img = conv2 (img, blur, 'same');
[Ix, Iy] = imgradientxy (img);
Ix = conv2 (Ix, blur, 'same');
Iy = conv2 (Iy, blur, 'same');
w = fspecial ('gaussian', [gw_i gw_i], sig_i);
wIx2 = conv2 (Ix .^ 2, w, 'same');
wIy2 = conv2 (Iy .^ 2, w, 'same');
wIxIy = conv2 (Ix .* Iy, w, 'same');

% construct H{i, j}
for i = 1: size (img, 1)
	for j = 1: size (img, 2)
		H{i, j} = [	wIx2(i, j)	wIxIy(i, j); ...
						wIxIy(i, j)	wIy2(i, j)];
	end
end

% calculate f_hm(i, j)
for i = 1: size(img, 1)
	for j = 1: size(img, 2)
		f_hm(i, j) = det (H{i, j}) / trace (H{i, j});
	end
end

% find feature
feat_points = (f_hm > th) & local_max(f_hm);

% return
[fp_loc(:, 1), fp_loc(:, 2)] = find (feat_points == 1);

% plot feature_points

imshow(img);
hold on;
[f_y, f_x] = find (feat_points == 1);
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