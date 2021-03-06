function [FP, Descriptor, Descriptor_vec, Coef] = MSOP_Feature ( input )
% get Y of input_image -> img
channel_num = size (input, 3);
if channel_num == 3
	input_yiq = rgb2ntsc (input);
    img = uint8(255 * input_yiq(:, :, 1));
elseif channel_num == 1
	img = input;
end

%% parameters
% how many Feature_Points per pic
FP_num = 500;

%% multi-scale detection
i = 1;
P = img;
while min([size(P, 1) size(P, 2)]) > 60 %&& i < 2
    tmp{i} = Interest_Point_Detection(P);
    layer_size(i, :) = [size(P, 1) size(P, 2)];
    layer{i} = P;
    P = downsampling (P);
    i = i+1;
end

% transform all IP to original scale
IP = [];
for i = 1: length(tmp)
    tmp_ip = tmp{i};
    if ~isempty(tmp_ip)
        for j = 1: length(tmp_ip)
            tmp_ip(j).global_x = layer_size(1, 2)/layer_size(i, 2) * (tmp_ip(j).x - 0.5) + 0.5;
            tmp_ip(j).global_y = layer_size(1, 1)/layer_size(i, 1) * (tmp_ip(j).y - 0.5) + 0.5;
            tmp_ip(j).l = i;
        end
        IP = [IP tmp_ip];
    end
end

% kill IP close to boundary
%{
i = 1;
while i <= length(IP)
    if IP(i).x < 30 || IP(i).y < 30 || size(img,2) - IP(i).x < 30 || size(img,1) - IP(i).y < 30
        IP(i) = [];
    else
        i = i + 1;
    end
end
%}

% to see if multi-scale IP is correct
%{
i = 3;
tmp_ip = tmp{i};
for j = 1: length(tmp_ip)
    tmp_ip(j).x = layer(1, 2)/layer(i, 2) * (tmp_ip(j).x - 0.5) + 0.5;
    tmp_ip(j).y = layer(1, 1)/layer(i, 1) * (tmp_ip(j).y - 0.5) + 0.5;
end
figure
imshow(input);
hold on;
for j = 1: length(tmp_ip)
    plot (tmp_ip(j).x, tmp_ip(j).y, 'ro');
end
hold off;
%}

%% ANMS

[tmp, index] = sort ([IP.f]);
IP = IP(index);
back = length(IP);
IP(back).r = Inf;
for i = 1: back-1
    start = find([IP.f] > 1.11 * IP(i).f, 1);
    sub_x = [IP(start:back).x];
    sub_y = [IP(start:back).y];
    dis = sqrt((sub_x-IP(i).x).^2 + (sub_y-IP(i).y).^2);
    IP(i).r = min (dis);
end

[tmp, index] = sort ([IP.r], 'descend');
IP = IP(index);
FP = IP(1:FP_num);

% show top 500 FP
%{
figure
imshow(input);
hold on;
for j = 1: FP_num
    plot (IP(j).x, IP(j).y, 'ro');
end
hold off;
%}

%% make descriptor

[Descriptor, Descriptor_vec, Coef] = Feature_Descriptor(FP, layer);

end

function output = downsampling (input)
gw_d = 5;   sig_d = 1;
blur = fspecial ('gaussian', [gw_d gw_d], sig_d);
input = imfilter(input, blur, 'replicate');
%output = input(1:2:size(input, 1), 1:2:size(input, 2));
lh = ceil (size (input, 1) / 2);
lw = ceil (size (input, 2) / 2);
output = imresize (input, [lh lw]);
end


