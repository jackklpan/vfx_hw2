function [descriptor, descriptor_vec, HaarWT_Coef] = Feature_Descriptor( FP, input )
%% blur image
gw_d = 10;   sig_d = 2;
blur = fspecial ('gaussian', [gw_d gw_d], sig_d);
img = imfilter(input, blur, 'replicate');

%% get descriptor
patch = zeros(40);
for i = 1: length(FP)
    % generate 40 position around FP
    des_pos = translate (FP(i));
    for v = 1: 40
        for u = 1: 40
            pos = des_pos{v, u};
            patch(v, u) = img(pos(2), pos(1));            
        end
    end
    des = imresize(patch, 1/5);
    % get descriptor
    descriptor{i} = descriptor_normalize (des);
    % get vector descriptor
    descriptor_vec{i} = reshape(descriptor{i}, 64, 1);
    % get Haar WT coeficient
    HaarWT_Coef{i} = HaarWT(descriptor_vec{i}');
end

end

function descriptor_position = translate (center)
% v = vertical, u = horizontal
dv = -center.orient;
du = [-dv(2); dv(1)];
c = cross ([dv; 0]', [du; 0]');
if c(3) > 0
    du = -du;
end

start = [center.x; center.y] - 20.5 * dv - 20.5 * du;

for i = 1: 40
    for j = 1: 40
        position = start + i * dv + j * du;
        descriptor_position{i, j} = [round(position(1)); round(position(2))];        
    end
end

end

function des_out = descriptor_normalize (des_in)

u = sum (des_in(:)) / 64;
sig = sqrt (sum(sum ((des_in - u) .^ 2)) / 64);

des_out = (des_in - u) / sig;

end

function Coef = HaarWT (des_vec)

w = ones (4);
b = -ones(4);

dx = [b w;...
           b w];
dy = [b b;...
           w w];
dxdy = [w b;...
                b w];

dx_vec = reshape(dx, 1, 64);
dy_vec = reshape(dy, 1, 64);
dxdy_vec = reshape(dxdy, 1, 64);

Coef = [dx_vec; dy_vec; dxdy_vec] * des_vec';

end