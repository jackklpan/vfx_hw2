function [ x, rotated, rotated_image ] = do_rotation_fit( FP1, FP2, image2, inlier_index )

    FPI1 = FP1(inlier_index, :);
    FPI2 = FP2(inlier_index, :);
    
    for i=1:length(FPI2)
        A(i*3+1, :) = [FPI2(i, 1) FPI2(i, 2) 1 0 0 0 0 0 0];
        A(i*3+2, :) = [0 0 0 FPI2(i, 1) FPI2(i, 2) 1 0 0 0];
        A(i*3+3, :) = [0 0 0 0 0 0 FPI2(i, 1) FPI2(i, 2) 1];
        b(i*3+1) = FPI1(i, 1);
        b(i*3+2) = FPI1(i, 2);
        b(i*3+3) = 1;
    end
    
    x = A\b';
    x = reshape(x, 3, 3);
    x(1, 3) = 0;
    x(2, 3) = 0;
    x(3, 3) = 1;
    
    x_tmp = x;
    x_tmp(3, 1) = 0;
    x_tmp(3, 2) = 0;
    
    if abs(asin(x_tmp(2, 1))*180/pi) > 1
        t = maketform('affine', x_tmp);
        rotated_image = imtransform(image2, t, 'XData',[1 size(image2, 2)], 'YData',[1 size(image2, 1)]);
        
        rotated = true;
    else
        rotated_image = image2;
        
        rotated = false;
    end
    
end

