function [ cylindrical_img ] = warp_to_cylindrical( image, f )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    s = f;
    image_size = size(image);
    max_x = ceil( s * atan( image_size(2)/2/f ) );
    max_y = ceil( s * (image_size(1)/2 / f) );
    cylindrical_img = uint8(zeros(image_size(1), image_size(2), 3));
    
    for row=1:max_y
        for col=1:max_x
            x = floor( tan( col/s ) * f );
            y = floor( row / s * sqrt(x*x+f*f) );
            
            if( x>0 && x<=image_size(2) && y>0 && y<=image_size(1) )
                cylindrical_img(row, col, :) = image(y, x, :);
            else
                cylindrical_img(row, col, :) = [0, 0, 0];
            end
        end
    end
end

