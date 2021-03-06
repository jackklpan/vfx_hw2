function IP = Interest_Point_Detection ( img )
%% parameters
% gaussian-- d:blur, i:window, o:orientation
gw_d = 5;   sig_d = 1;
gw_i = 7;   sig_i = 1.5;
gw_o = 15;  sig_o = 4.5;
% threshold
th = 10;

%%  Calculate Response function -> f_hm(i, j)
blur = fspecial ('gaussian', [gw_d gw_d], sig_d);
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
f_hm = zeros (size(img));
for i = 1: size(img, 1)
	for j = 1: size(img, 2)
		f_hm(i, j) = det (H{i, j}) / trace (H{i, j});
	end
end

%% find feature
interest_points = (f_hm > th) & local_max2(f_hm);
[ip_loc(:, 1), ip_loc(:, 2)] = find (interest_points == 1);

IP = [];
blur = fspecial ('gaussian', [gw_o gw_o], sig_o);
[ux, uy] = imgradientxy (img);
ux = conv2 (ux, blur, 'same');
uy = conv2 (uy, blur, 'same');

for i = 1: size(ip_loc, 1)
    IP(i).x = ip_loc(i, 2);
    IP(i).y = ip_loc(i, 1);
    IP(i).f = f_hm(IP(i).y, IP(i).x);
    u = [ux(IP(i).y, IP(i).x); uy(IP(i).y, IP(i).x)];
    IP(i).orient = u / norm(u);
end

%% sub-pixel accuracy refinement
for i = 1: length(IP)
    x = IP(i).x;
    y = IP(i).y;
    Df = [(f_hm(y, x+1)-f_hm(y, x-1))/2; ...
                (f_hm(y+1, x)-f_hm(y-1, x))/2];
    D2f = [f_hm(y, x+1)+f_hm(y, x-1)-2*f_hm(y, x) ...
                (f_hm(y+1, x+1)+f_hm(y-1, x-1)-f_hm(y-1, x+1)-f_hm(y+1, x-1))/4; ...
                (f_hm(y+1, x+1)+f_hm(y-1, x-1)-f_hm(y-1, x+1)-f_hm(y+1, x-1))/4 ...
                f_hm(y+1, x)+f_hm(y-1, x)-2*f_hm(y, x)];
    xm = - inv(D2f) * Df;
    IP(i).x = IP(i).x + xm(1);
    IP(i).y = IP(i).y + xm(2);
    IP(i).f = IP(i).f + Df' * xm + 0.5 * xm' * D2f * xm;
end
    
%% kill IP close to boundary
i = 1;
while i <= length(IP)
    if IP(i).x < 30 || IP(i).y < 30 || size(img,2) - IP(i).x < 30 || size(img,1) - IP(i).y < 30
        IP(i) = [];
    else
        i = i + 1;
    end
end

%% plot feature_points
%{
figure
imshow(img);
hold on;
[f_y, f_x] = find (interest_points == 1);
plot (f_x, f_y, 'ro');
%hold off;
for i = 1: length(IP)
    plot(IP(i).x, IP(i).y, 'xb');
end
hold off;
%}
end

function pks = local_max (arr)

pks = zeros(size (arr, 1), size (arr, 2));

for i = 2: size(arr, 1) - 1
    for j = 2: size(arr, 2) - 1
        s = i - 1;
        t = j - 1;
        patch = arr(s:s+2, t:t+2);
        patch(5) = [];
        
        if max(patch(:)) < arr(i, j)
            pks(i, j) = 1;
        end
    end
end

end

function pks = local_max2 (arr)

arr_size = size(arr);
pks = zeros(arr_size(1), arr_size(2));

mid = reshape(arr(2:arr_size(1) - 1, 2:arr_size(2) - 1), 1, []);
p1 = reshape(arr(1:arr_size(1) - 2, 1:arr_size(2) - 2), 1, []);
p2 = reshape(arr(2:arr_size(1) - 1, 1:arr_size(2) - 2), 1, []);
p3 = reshape(arr(3:arr_size(1), 1:arr_size(2) - 2), 1, []);
p4 = reshape(arr(1:arr_size(1) - 2, 2:arr_size(2) - 1), 1, []);
p6 = reshape(arr(3:arr_size(1), 2:arr_size(2) - 1), 1, []);
p7 = reshape(arr(1:arr_size(1) - 2, 3:arr_size(2)), 1, []);
p8 = reshape(arr(2:arr_size(1) - 1, 3:arr_size(2)), 1, []);
p9 = reshape(arr(3:arr_size(1), 3:arr_size(2)), 1, []);

patch = [p1; p2; p3; p4; p6; p7; p8; p9];

result = (mid > max(patch));
pks(2:arr_size(1) - 1, 2:arr_size(2) - 1) = reshape (result, arr_size(1)-2, arr_size(2)-2);

end
