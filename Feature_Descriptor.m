function descriptor = Feature_Descriptor( FP, layer )
gw_d = 10;   sig_d = 2;
blur = fspecial ('gaussian', [gw_d gw_d], sig_d);

for i = 1: length(layer)
    img{i} = imfilter(layer{i}, blur, 'replicate');
end

patch = zeros(40);
for i = 1: length(FP)
    des_pos = translate (FP(i));
    for v = 1: 40
        for u = 1: 40
            pos = des_pos{v, u};
            patch(v, u) = img{FP(i).l}(pos(2), pos(1));            
        end
    end
     des = imresize(patch, 1/5);
     descriptor{i} = descriptor_normalize (des);
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