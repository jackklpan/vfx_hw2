function [ out_im ] = translation_image( im, tx, ty )
    t = maketform('affine',[1 0 ; 0 1; tx ty]);
    out_im = imtransform(im, t, 'XData',[1 size(im,2)+abs(tx)], 'YData',[1 size(im,1)+abs(ty)]);
    %out_im = imtransform(im, t);
end

