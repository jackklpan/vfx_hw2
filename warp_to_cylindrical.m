function [ cylindrical_img ] = warp_to_cylindrical( image, f )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    s = f;
    
    image_size = size(image);
    image_half_size = round(image_size/2);
    max_x = ceil( s * atan( image_size(2)/2/f ) ) * 2;
    max_y = ceil( s * (image_size(1) / f) );
    half_x = round(max_x/2);
    half_y = round(max_y/2);
    
    cylindrical_img = uint8(zeros(max_y, max_x, 3));
    
    for row=1:max_y
        for col=1:max_x
            x = floor( tan( (col-half_x)/s ) * f );
            y = floor( (row-half_y) / s * sqrt(x*x+f*f) ) + image_half_size(1);
            x = x + image_half_size(2);
            
            if( x>0 && x<=image_size(2) && y>0 && y<=image_size(1) )
                cylindrical_img(row, col, :) = image(y, x, :);
            else
                cylindrical_img(row, col, :) = [0, 0, 0];
            end
        end
    end
end

